import { FormEvent } from 'react';
import type { Invoice, Payment } from './types';

interface PaymentModalProps {
  invoice: Invoice;
  payments: Payment[];
  loadingPayments: boolean;
  paymentForm: { amount: string; method: string };
  setPaymentForm: (f: { amount: string; method: string }) => void;
  paymentFormError: string;
  setPaymentFormError: (s: string) => void;
  paidSoFar: number;
  remainingBalance: number;
  creatingPayment: boolean;
  onSubmit: (e: FormEvent) => void;
  onClose: () => void;
  inputClass: string;
}

export default function PaymentModal({
  invoice,
  payments,
  loadingPayments,
  paymentForm,
  setPaymentForm,
  paymentFormError,
  setPaymentFormError,
  paidSoFar,
  remainingBalance,
  creatingPayment,
  onSubmit,
  onClose,
  inputClass,
}: PaymentModalProps) {
  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-50 p-4">
      <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6 w-full max-w-lg">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-bold text-white">
            Registrar Pagamento - Fatura #{invoice.id}
          </h2>
          <button
            className="text-zinc-400 hover:text-white text-xl"
            onClick={onClose}
          >
            &times;
          </button>
        </div>

        {/* Existing payments */}
        {loadingPayments ? (
          <p className="text-zinc-400 text-sm mb-4">Carregando pagamentos...</p>
        ) : payments.length > 0 ? (
          <div className="mb-4">
            <p className="text-xs uppercase tracking-wider text-zinc-500 font-medium mb-2">
              Pagamentos anteriores
            </p>
            <div className="space-y-1">
              {payments.map((pay) => (
                <div key={pay.id} className="flex justify-between text-xs text-zinc-300">
                  <span>R$ {Number(pay.amount).toFixed(2)} ({pay.method || 'N/A'})</span>
                  <span className="text-zinc-500">
                    {pay.paid_at ? new Date(pay.paid_at).toLocaleDateString('pt-BR') : '—'}
                  </span>
                </div>
              ))}
            </div>
          </div>
        ) : null}

        {/* Saldo devedor (informativo) */}
        <div className="mb-3 text-xs text-zinc-400">
          <span>Total da fatura: </span>
          <span className="text-zinc-200 font-medium">R$ {Number(invoice.amount).toFixed(2)}</span>
          <span className="mx-2">·</span>
          <span>Já pago: </span>
          <span className="text-zinc-200 font-medium">R$ {paidSoFar.toFixed(2)}</span>
          <span className="mx-2">·</span>
          <span>Saldo devedor: </span>
          <span className="text-yellow-400 font-medium">R$ {remainingBalance.toFixed(2)}</span>
        </div>

        <form onSubmit={onSubmit} className="space-y-3">
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Valor (R$)</label>
            <input
              type="number"
              step="0.01"
              min="0.01"
              max={remainingBalance}
              className={inputClass}
              value={paymentForm.amount}
              onChange={(e) => {
                setPaymentForm({ ...paymentForm, amount: e.target.value });
                if (paymentFormError) setPaymentFormError('');
              }}
            />
            {paymentFormError && (
              <p className="text-red-400 text-xs mt-1">{paymentFormError}</p>
            )}
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Metodo</label>
            <select
              className={inputClass}
              value={paymentForm.method}
              onChange={(e) => setPaymentForm({ ...paymentForm, method: e.target.value })}
            >
              <option value="pix">PIX</option>
              <option value="boleto">Boleto</option>
              <option value="credit_card">Cartao de Credito</option>
              <option value="debit_card">Cartao de Debito</option>
              <option value="transfer">Transferencia</option>
              <option value="cash">Dinheiro</option>
            </select>
          </div>
          <div className="flex gap-2">
            <button
              type="submit"
              disabled={creatingPayment}
              className="px-4 py-2 bg-yellow-500 text-zinc-900 font-semibold rounded-lg hover:bg-yellow-400 transition-colors disabled:opacity-50"
            >
              {creatingPayment ? 'Registrando...' : 'Registrar Pagamento'}
            </button>
            <button
              type="button"
              className="px-4 py-2 bg-zinc-800 text-zinc-300 rounded-lg hover:bg-zinc-700 transition-colors"
              onClick={onClose}
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
