import { useState, useEffect, useCallback, FormEvent } from 'react';
import {
  fetchCoupons,
  createCoupon,
  updateCoupon,
} from '../../../services/adminApi';
import type { Coupon } from './types';

interface CouponsTabProps {
  inputClass: string;
}

export default function CouponsTab({ inputClass }: CouponsTabProps) {
  const [coupons, setCoupons] = useState<Coupon[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // ── Create form ──
  const [form, setForm] = useState({
    code: '',
    discount_type: 'percentage',
    discount_value: '',
    max_usages: '',
    expires_at: '',
    description: '',
  });
  const [creating, setCreating] = useState(false);

  const loadCoupons = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetchCoupons();
      const items = Array.isArray(res) ? res : (res as Record<string, unknown>).items as Coupon[] || [];
      setCoupons(items);
    } catch (e) {
      console.error(e);
      /* TODO: toast */
      setCoupons([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadCoupons();
  }, [loadCoupons]);

  const handleCreate = async (e: FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    if (!form.code || !form.discount_value) {
      setError('Codigo e valor do desconto sao obrigatorios.');
      return;
    }
    const discountValue = parseFloat(form.discount_value);
    if (!Number.isFinite(discountValue) || discountValue < 0) {
      setError('Valor do desconto deve ser maior ou igual a zero.');
      return;
    }
    if (form.discount_type === 'percentage' && discountValue > 100) {
      setError('Desconto percentual nao pode ser maior que 100%.');
      return;
    }
    setCreating(true);
    try {
      await createCoupon({
        code: form.code,
        discount_type: form.discount_type,
        discount_value: discountValue,
        max_usages: form.max_usages ? parseInt(form.max_usages) : 0,
        expires_at: form.expires_at || null,
        description: form.description,
      });
      setSuccess('Cupom criado!');
      setForm({ code: '', discount_type: 'percentage', discount_value: '', max_usages: '', expires_at: '', description: '' });
      loadCoupons();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Erro ao criar cupom.');
    } finally {
      setCreating(false);
    }
  };

  const handleToggleActive = async (coupon: Coupon) => {
    setError('');
    // Confirmação dupla apenas para DESATIVAR (operação que afeta usuários).
    // Reativar é menos crítico.
    // TODO Wave 4: trocar window.confirm por ConfirmDialog unificado.
    if (coupon.is_active) {
      const ok1 = window.confirm(
        `Desativar o cupom ${coupon.code}? Usuários não poderão mais aplicá-lo.`,
      );
      if (!ok1) return;
      const ok2 = window.confirm(
        `Confirmar definitivamente a desativação do cupom ${coupon.code}?`,
      );
      if (!ok2) return;
    }
    try {
      await updateCoupon(coupon.id, { is_active: !coupon.is_active });
      loadCoupons();
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : 'Erro ao alterar status do cupom.');
    }
  };

  return (
    <div className="space-y-6">
      {/* Create form */}
      <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6">
        <p className="text-xs uppercase tracking-wider text-zinc-500 font-medium mb-4">
          Novo Cupom
        </p>
        <form onSubmit={handleCreate} className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-3 items-end">
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Codigo *</label>
            <input
              type="text"
              className={inputClass}
              value={form.code}
              onChange={(e) => setForm({ ...form, code: e.target.value.toUpperCase() })}
              placeholder="EX: DESCONTO20"
            />
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Tipo</label>
            <select
              className={inputClass}
              value={form.discount_type}
              onChange={(e) => setForm({ ...form, discount_type: e.target.value })}
            >
              <option value="percentage">Percentual (%)</option>
              <option value="fixed">Valor fixo (R$)</option>
            </select>
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Valor *</label>
            <input
              type="number"
              step="0.01"
              min="0"
              max={form.discount_type === 'percentage' ? 100 : undefined}
              className={inputClass}
              value={form.discount_value}
              onChange={(e) => setForm({ ...form, discount_value: e.target.value })}
              placeholder={form.discount_type === 'percentage' ? '20' : '50.00'}
            />
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Max usos</label>
            <input
              type="number"
              className={inputClass}
              value={form.max_usages}
              onChange={(e) => setForm({ ...form, max_usages: e.target.value })}
              placeholder="0 = ilimitado"
            />
          </div>
          <div>
            <label className="block text-sm text-zinc-400 mb-1">Expira em</label>
            <input
              type="date"
              className={inputClass}
              value={form.expires_at}
              onChange={(e) => setForm({ ...form, expires_at: e.target.value })}
            />
          </div>
          <button
            type="submit"
            disabled={creating}
            className="px-4 py-2 bg-yellow-500 text-zinc-900 font-semibold rounded-lg hover:bg-yellow-400 transition-colors disabled:opacity-50"
          >
            {creating ? 'Criando...' : 'Criar Cupom'}
          </button>
        </form>
        <div className="mt-3">
          <label className="block text-sm text-zinc-400 mb-1">Descricao</label>
          <input
            type="text"
            className={inputClass + ' max-w-md'}
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
            placeholder="Descricao opcional"
          />
        </div>
        {error && <p className="text-red-400 text-sm mt-2">{error}</p>}
        {success && <p className="text-green-400 text-sm mt-2">{success}</p>}
      </div>

      {/* Coupons table */}
      <div className="bg-zinc-900 border border-zinc-800 rounded-xl p-6">
        {loading ? (
          <p className="text-zinc-400 text-sm py-8 text-center">Carregando...</p>
        ) : coupons.length === 0 ? (
          <p className="text-zinc-500 text-sm py-8 text-center">Nenhum cupom cadastrado.</p>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-zinc-950 text-zinc-400 uppercase text-xs">
                <tr>
                  <th className="p-3">Codigo</th>
                  <th className="p-3">Desconto</th>
                  <th className="p-3">Usos</th>
                  <th className="p-3">Expira</th>
                  <th className="p-3">Status</th>
                  <th className="p-3">Acoes</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-zinc-800">
                {coupons.map((coupon) => (
                  <tr key={coupon.id} className="hover:bg-zinc-800/50">
                    <td className="p-3 text-white font-mono font-medium">{coupon.code}</td>
                    <td className="p-3 text-zinc-300">
                      {coupon.discount_type === 'percentage'
                        ? `${coupon.discount_value}%`
                        : `R$ ${Number(coupon.discount_value).toFixed(2)}`}
                    </td>
                    <td className="p-3 text-zinc-300">
                      {coupon.current_usages ?? 0} / {coupon.max_usages || '---'}
                    </td>
                    <td className="p-3 text-zinc-400 text-xs">
                      {coupon.expires_at
                        ? new Date(coupon.expires_at).toLocaleDateString('pt-BR')
                        : 'Sem expiracao'}
                    </td>
                    <td className="p-3">
                      {coupon.is_active ? (
                        <span className="bg-green-500/10 text-green-500 px-2 py-0.5 rounded text-xs font-medium">
                          Ativo
                        </span>
                      ) : (
                        <span className="bg-red-500/10 text-red-500 px-2 py-0.5 rounded text-xs font-medium">
                          Inativo
                        </span>
                      )}
                    </td>
                    <td className="p-3">
                      <button
                        className="text-red-400 hover:text-red-300 text-sm"
                        onClick={() => handleToggleActive(coupon)}
                      >
                        {coupon.is_active ? 'Desativar' : 'Ativar'}
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
