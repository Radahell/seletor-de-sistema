import { useState, useEffect, useCallback, FormEvent } from 'react';
import {
  fetchLoyaltyBalance,
  fetchLoyaltyHistory,
  creditLoyalty,
  debitLoyalty,
  type Establishment,
} from '../../../services/adminApi';
import type { LoyaltyEntry } from './types';

interface LoyaltyTabProps {
  establishments: Establishment[];
  inputClass: string;
}

export default function LoyaltyTab({ establishments, inputClass }: LoyaltyTabProps) {
  const [selectedEstId, setSelectedEstId] = useState('');
  const [balance, setBalance] = useState<number | null>(null);
  const [history, setHistory] = useState<LoyaltyEntry[]>([]);
  const [loadingData, setLoadingData] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // ── Transaction form ──
  const [txForm, setTxForm] = useState({ type: 'credit', points: '', reason: '' });
  const [submitting, setSubmitting] = useState(false);

  const loadLoyaltyData = useCallback(async () => {
    if (!selectedEstId) {
      setBalance(null);
      setHistory([]);
      return;
    }
    setLoadingData(true);
    setError('');
    try {
      const estId = Number(selectedEstId);
      const balRes = await fetchLoyaltyBalance(estId);
      const b = balRes as Record<string, unknown>;
      setBalance((b.balance as number) ?? (b.points as number) ?? 0);

      const histRes = await fetchLoyaltyHistory(estId);
      const items = Array.isArray(histRes)
        ? histRes
        : (histRes as Record<string, unknown>).items as LoyaltyEntry[] || [];
      setHistory(items);
    } catch (e) {
      console.error(e);
      /* TODO: toast */
      setBalance(null);
      setHistory([]);
    } finally {
      setLoadingData(false);
    }
  }, [selectedEstId]);

  useEffect(() => {
    loadLoyaltyData();
  }, [loadLoyaltyData]);

  const handleTransaction = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (!selectedEstId || !txForm.points) {
      setError('Selecione um estabelecimento e informe os pontos.');
      return;
    }
    const points = parseInt(txForm.points);
    if (!Number.isFinite(points) || Number.isNaN(points) || points <= 0) {
      setError('Pontos devem ser um número inteiro maior que zero.');
      return;
    }
    // Confirmação dupla para DÉBITO (subtrai saldo do cliente).
    // TODO Wave 4: trocar window.confirm por ConfirmDialog unificado.
    if (txForm.type === 'debit') {
      const ok1 = window.confirm(
        `Debitar ${points} pontos do saldo de fidelidade? Saldo atual: ${balance ?? 0}.`,
      );
      if (!ok1) return;
      const ok2 = window.confirm(
        `Confirmar definitivamente o débito de ${points} pontos?`,
      );
      if (!ok2) return;
    }
    setSubmitting(true);
    try {
      const estId = Number(selectedEstId);
      const payload = { points, reason: txForm.reason };
      if (txForm.type === 'credit') {
        await creditLoyalty(estId, payload);
      } else {
        await debitLoyalty(estId, payload);
      }
      setSuccess(`${txForm.type === 'credit' ? 'Credito' : 'Debito'} registrado!`);
      setTxForm({ type: 'credit', points: '', reason: '' });
      loadLoyaltyData();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Erro ao registrar transacao.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Establishment select */}
      <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6">
        <p className="text-xs uppercase tracking-wider text-zinc-500 font-medium mb-4">
          Programa de Fidelidade
        </p>
        <div className="max-w-md">
          <label className="block text-sm text-zinc-400 mb-1">Estabelecimento</label>
          <select
            className={inputClass}
            value={selectedEstId}
            onChange={(e) => setSelectedEstId(e.target.value)}
          >
            <option value="">Selecionar estabelecimento...</option>
            {establishments.map((est) => (
              <option key={est.id} value={String(est.id)}>{est.name}</option>
            ))}
          </select>
        </div>

        {/* Balance KPI */}
        {selectedEstId && (
          <div className="mt-4">
            {loadingData ? (
              <p className="text-zinc-400 text-sm">Carregando...</p>
            ) : (
              <div className="inline-flex items-center gap-3 bg-zinc-950 border border-zinc-800 rounded-lg px-6 py-4">
                <div>
                  <p className="text-xs uppercase tracking-wider text-zinc-500 font-medium">Saldo</p>
                  <p className="text-3xl font-bold text-yellow-500">{balance ?? 0}</p>
                  <p className="text-xs text-zinc-400">pontos</p>
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Transaction form */}
      {selectedEstId && (
        <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6">
          <p className="text-xs uppercase tracking-wider text-zinc-500 font-medium mb-4">
            Nova Transacao
          </p>
          <form onSubmit={handleTransaction} className="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
            <div>
              <label className="block text-sm text-zinc-400 mb-1">Tipo</label>
              <select
                className={inputClass}
                value={txForm.type}
                onChange={(e) => setTxForm({ ...txForm, type: e.target.value })}
              >
                <option value="credit">Credito (+)</option>
                <option value="debit">Debito (-)</option>
              </select>
            </div>
            <div>
              <label className="block text-sm text-zinc-400 mb-1">Pontos *</label>
              <input
                type="number"
                className={inputClass}
                value={txForm.points}
                onChange={(e) => setTxForm({ ...txForm, points: e.target.value })}
                placeholder="100"
                min={1}
              />
            </div>
            <div>
              <label className="block text-sm text-zinc-400 mb-1">Motivo</label>
              <input
                type="text"
                className={inputClass}
                value={txForm.reason}
                onChange={(e) => setTxForm({ ...txForm, reason: e.target.value })}
                placeholder="Ex: Bonus mensal"
              />
            </div>
            <button
              type="submit"
              disabled={submitting}
              className="px-4 py-2 bg-yellow-500 text-zinc-900 font-semibold rounded-lg hover:bg-yellow-400 transition-colors disabled:opacity-50"
            >
              {submitting ? 'Registrando...' : 'Registrar'}
            </button>
          </form>
          {error && <p className="text-red-400 text-sm mt-2">{error}</p>}
          {success && <p className="text-green-400 text-sm mt-2">{success}</p>}
        </div>
      )}

      {/* History table */}
      {selectedEstId && (
        <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6">
          <p className="text-xs uppercase tracking-wider text-zinc-500 font-medium mb-4">
            Historico de Transacoes
          </p>
          {loadingData ? (
            <p className="text-zinc-400 text-sm py-4">Carregando...</p>
          ) : history.length === 0 ? (
            <p className="text-zinc-500 text-sm py-4">Nenhuma transacao registrada.</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-left text-sm">
                <thead className="bg-zinc-950 text-zinc-400 uppercase text-xs">
                  <tr>
                    <th className="p-3">Data</th>
                    <th className="p-3">Tipo</th>
                    <th className="p-3">Pontos</th>
                    <th className="p-3">Motivo</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-zinc-800">
                  {history.map((tx) => (
                    <tr key={tx.id} className="hover:bg-zinc-800/50">
                      <td className="p-3 text-zinc-400 text-xs whitespace-nowrap">
                        {tx.created_at
                          ? new Date(tx.created_at).toLocaleString('pt-BR')
                          : '—'}
                      </td>
                      <td className="p-3">
                        {tx.type === 'credit' ? (
                          <span className="bg-green-500/10 text-green-500 px-2 py-0.5 rounded text-xs font-medium">
                            Credito
                          </span>
                        ) : (
                          <span className="bg-red-500/10 text-red-500 px-2 py-0.5 rounded text-xs font-medium">
                            Debito
                          </span>
                        )}
                      </td>
                      <td className="p-3 text-white font-medium">
                        {tx.type === 'credit' ? '+' : '-'}{tx.points}
                      </td>
                      <td className="p-3 text-zinc-300">{tx.reason || '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
