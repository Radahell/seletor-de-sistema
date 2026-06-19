import { useState, useEffect, useCallback, FormEvent } from 'react';
import {
  fetchInvoices,
  createInvoice,
  updateInvoice,
  fetchPayments,
  createPayment,
  type Establishment,
} from '../../../services/adminApi';
import type { Invoice, Payment } from './types';
import PaymentModal from './PaymentModal';

interface InvoicesTabProps {
  establishments: Establishment[];
  inputClass: string;
}

export default function InvoicesTab({ establishments, inputClass }: InvoicesTabProps) {
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [loading, setLoading] = useState(false);
  const [statusFilter, setStatusFilter] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // ── Create form ──
  const [form, setForm] = useState({
    establishment_id: '',
    amount: '',
    due_date: '',
    reference_period: '',
    description: '',
  });
  const [creating, setCreating] = useState(false);

  // ── Payment modal ──
  const [paymentInvoice, setPaymentInvoice] = useState<Invoice | null>(null);
  const [payments, setPayments] = useState<Payment[]>([]);
  const [loadingPayments, setLoadingPayments] = useState(false);
  const [paymentForm, setPaymentForm] = useState({ amount: '', method: '' });
  const [creatingPayment, setCreatingPayment] = useState(false);
  const [paymentIdempotencyKey, setPaymentIdempotencyKey] = useState<string>('');
  const [paymentFormError, setPaymentFormError] = useState('');

  // Soma de pagamentos já lançados para a fatura aberta
  const paidSoFar = payments.reduce((acc, p) => acc + Number(p.amount || 0), 0);
  const remainingBalance = paymentInvoice
    ? Math.max(0, Number(paymentInvoice.amount) - paidSoFar)
    : 0;

  const loadInvoices = useCallback(async () => {
    setLoading(true);
    try {
      const params: Record<string, string> = {};
      if (statusFilter) params.status = statusFilter;
      const res = await fetchInvoices(params);
      const items = Array.isArray(res) ? res : (res as Record<string, unknown>).items as Invoice[] || [];
      setInvoices(items);
    } catch (e) {
      console.error(e);
      /* TODO: toast */
      setInvoices([]);
    } finally {
      setLoading(false);
    }
  }, [statusFilter]);

  useEffect(() => {
    loadInvoices();
  }, [loadInvoices]);

  const handleCreate = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (!form.establishment_id || !form.amount || !form.due_date) {
      setError('Estabelecimento, valor e vencimento sao obrigatorios.');
      return;
    }
    setCreating(true);
    try {
      await createInvoice({
        establishment_id: Number(form.establishment_id),
        amount: parseFloat(form.amount),
        due_date: form.due_date,
        reference_period: form.reference_period,
        description: form.description,
      });
      setSuccess('Fatura criada!');
      setForm({ establishment_id: '', amount: '', due_date: '', reference_period: '', description: '' });
      loadInvoices();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Erro ao criar fatura.');
    } finally {
      setCreating(false);
    }
  };

  const openPaymentModal = async (inv: Invoice) => {
    // Limpa pagamentos da fatura anterior IMEDIATAMENTE para evitar que
    // paidSoFar/remainingBalance usem state stale enquanto fetchPayments resolve.
    setPayments([]);
    setPaymentInvoice(inv);
    setPaymentForm({ amount: String(inv.amount), method: 'pix' });
    setPaymentFormError('');
    // Gera um idempotency-key novo ao abrir o modal — protege contra
    // duplo clique / retries de rede dentro da mesma "intenção" de pagamento.
    setPaymentIdempotencyKey(
      typeof crypto !== 'undefined' && 'randomUUID' in crypto
        ? crypto.randomUUID()
        : `pay-${inv.id}-${Date.now()}-${Math.random().toString(36).slice(2)}`,
    );
    setLoadingPayments(true);
    try {
      const res = await fetchPayments(inv.id);
      const items = Array.isArray(res) ? res : (res as Record<string, unknown>).items as Payment[] || [];
      setPayments(items);
    } catch (e) {
      console.error(e);
      /* TODO: toast */
      setPayments([]);
    } finally {
      setLoadingPayments(false);
    }
  };

  const handleCreatePayment = async (e: FormEvent) => {
    e.preventDefault();
    if (!paymentInvoice) return;
    setPaymentFormError('');
    setError('');

    const amount = parseFloat(paymentForm.amount);
    if (!Number.isFinite(amount) || amount <= 0) {
      setPaymentFormError('Valor deve ser maior que zero.');
      return;
    }
    // Tolerância de 1 centavo p/ arredondamentos
    if (amount > remainingBalance + 0.005) {
      setPaymentFormError(
        `Valor (R$ ${amount.toFixed(2)}) excede o saldo devedor (R$ ${remainingBalance.toFixed(2)}).`,
      );
      return;
    }

    setCreatingPayment(true);
    try {
      await createPayment(
        paymentInvoice.id,
        {
          amount,
          method: paymentForm.method,
        },
        paymentIdempotencyKey,
      );
      setSuccess('Pagamento registrado!');
      setPaymentInvoice(null);
      loadInvoices();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Erro ao registrar pagamento.');
    } finally {
      setCreatingPayment(false);
    }
  };

  const handleMarkStatus = async (inv: Invoice, newStatus: string) => {
    setError('');
    // Confirmação dupla para CANCELAR fatura (operação destrutiva).
    // TODO Wave 4: trocar window.confirm por ConfirmDialog unificado.
    if (newStatus === 'cancelled') {
      const valor = Number(inv.amount).toFixed(2);
      const ok1 = window.confirm(
        `Cancelar a fatura #${inv.id} no valor de R$ ${valor}? Essa ação marca a fatura como cancelada e pode liberar mensalidade.`,
      );
      if (!ok1) return;
      const ok2 = window.confirm(
        `Confirmar definitivamente o cancelamento da fatura #${inv.id} (R$ ${valor})?`,
      );
      if (!ok2) return;
    }
    try {
      await updateInvoice(inv.id, { status: newStatus });
      loadInvoices();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Erro ao atualizar status.');
    }
  };

  const getEstName = (estId: number) => {
    const est = establishments.find((e) => e.id === estId);
    return est?.name || `#${estId}`;
  };

  const statusBadge = (status: string) => {
    switch (status) {
      case 'paid':
        return (
          <span className="bg-green-500/10 text-green-500 px-2 py-0.5 rounded text-xs font-medium">
            Pago
          </span>
        );
      case 'overdue':
        return (
          <span className="bg-red-500/10 text-red-500 px-2 py-0.5 rounded text-xs font-medium">
            Vencida
          </span>
        );
      case 'cancelled':
        return (
          <span className="bg-zinc-700 text-zinc-300 px-2 py-0.5 rounded text-xs font-medium">
            Cancelada
          </span>
        );
      default:
        return (
          <span className="bg-yellow-500/10 text-yellow-500 px-2 py-0.5 rounded text-xs font-medium">
            Pendente
          </span>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Create form */}
      <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6">
        <p className="text-xs uppercase tracking-wider text-zinc-500 font-medium mb-4">
          Nova Fatura
        </p>
        <form onSubmit={handleCreate} className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-3 items-end">
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Estabelecimento *</label>
            <select
              className={inputClass}
              value={form.establishment_id}
              onChange={(e) => setForm({ ...form, establishment_id: e.target.value })}
            >
              <option value="">Selecionar...</option>
              {establishments.map((est) => (
                <option key={est.id} value={String(est.id)}>{est.name}</option>
              ))}
            </select>
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Valor (R$) *</label>
            <input
              type="number"
              step="0.01"
              className={inputClass}
              value={form.amount}
              onChange={(e) => setForm({ ...form, amount: e.target.value })}
              placeholder="0.00"
            />
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Vencimento *</label>
            <input
              type="date"
              className={inputClass}
              value={form.due_date}
              onChange={(e) => setForm({ ...form, due_date: e.target.value })}
            />
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Referencia</label>
            <input
              type="text"
              className={inputClass}
              value={form.reference_period}
              onChange={(e) => setForm({ ...form, reference_period: e.target.value })}
              placeholder="Ex: 2026-01"
            />
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Descricao</label>
            <input
              type="text"
              className={inputClass}
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              placeholder="Opcional"
            />
          </div>
          <button
            type="submit"
            disabled={creating}
            className="px-4 py-2 bg-yellow-500 text-zinc-900 font-semibold rounded-lg hover:bg-yellow-400 transition-colors disabled:opacity-50"
          >
            {creating ? 'Criando...' : 'Criar Fatura'}
          </button>
        </form>
        {error && <p className="text-red-400 text-sm mt-2">{error}</p>}
        {success && <p className="text-green-400 text-sm mt-2">{success}</p>}
      </div>

      {/* Filter + table */}
      <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6">
        <div className="flex items-center gap-3 mb-4">
          <select
            className={inputClass + ' max-w-xs'}
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="">Todos os status</option>
            <option value="pending">Pendente</option>
            <option value="paid">Pago</option>
            <option value="overdue">Vencida</option>
            <option value="cancelled">Cancelada</option>
          </select>
        </div>

        {loading ? (
          <p className="text-zinc-400 text-sm py-8 text-center">Carregando...</p>
        ) : invoices.length === 0 ? (
          <p className="text-zinc-500 text-sm py-8 text-center">Nenhuma fatura encontrada.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-zinc-950 text-zinc-400 uppercase text-xs">
                <tr>
                  <th className="p-3">ID</th>
                  <th className="p-3">Estabelecimento</th>
                  <th className="p-3">Valor</th>
                  <th className="p-3">Status</th>
                  <th className="p-3">Vencimento</th>
                  <th className="p-3">Referencia</th>
                  <th className="p-3">Acoes</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-800">
                {invoices.map((inv) => (
                  <tr key={inv.id} className="hover:bg-zinc-800/50">
                    <td className="p-3 text-zinc-400">#{inv.id}</td>
                    <td className="p-3 text-white">{inv.establishment_name || getEstName(inv.establishment_id)}</td>
                    <td className="p-3 text-white font-medium">
                      R$ {Number(inv.amount).toFixed(2)}
                    </td>
                    <td className="p-3">{statusBadge(inv.status)}</td>
                    <td className="p-3 text-zinc-400 text-xs">
                      {inv.due_date ? new Date(inv.due_date).toLocaleDateString('pt-BR') : '—'}
                    </td>
                    <td className="p-3 text-zinc-400 text-xs">{inv.reference_period || '—'}</td>
                    <td className="p-3">
                      <div className="flex items-center gap-2 flex-wrap">
                        {inv.status !== 'paid' && inv.status !== 'cancelled' && (
                          <button
                            className="px-4 py-2 bg-zinc-800 text-zinc-300 rounded-lg hover:bg-zinc-700 transition-colors text-xs"
                            onClick={() => openPaymentModal(inv)}
                          >
                            Pagar
                          </button>
                        )}
                        {inv.status === 'pending' && (
                          <button
                            className="text-red-400 hover:text-red-300 text-sm"
                            onClick={() => handleMarkStatus(inv, 'cancelled')}
                          >
                            Cancelar
                          </button>
                        )}
                        {inv.status === 'cancelled' && (
                          <button
                            className="text-red-400 hover:text-red-300 text-sm"
                            onClick={() => handleMarkStatus(inv, 'pending')}
                          >
                            Reabrir
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Payment modal */}
      {paymentInvoice && (
        <PaymentModal
          invoice={paymentInvoice}
          payments={payments}
          loadingPayments={loadingPayments}
          paymentForm={paymentForm}
          setPaymentForm={setPaymentForm}
          paymentFormError={paymentFormError}
          setPaymentFormError={setPaymentFormError}
          paidSoFar={paidSoFar}
          remainingBalance={remainingBalance}
          creatingPayment={creatingPayment}
          onSubmit={handleCreatePayment}
          onClose={() => setPaymentInvoice(null)}
          inputClass={inputClass}
        />
      )}
    </div>
  );
}
