import { useState, useEffect } from 'react';
import { Receipt, Tag, Star } from 'lucide-react';
import {
  fetchEstablishments,
  type Establishment,
} from '../../services/adminApi';
import InvoicesTab from './billing/InvoicesTab';
import CouponsTab from './billing/CouponsTab';
import LoyaltyTab from './billing/LoyaltyTab';

type Tab = 'invoices' | 'coupons' | 'loyalty';

export default function AdminBillingPage() {
  const [tab, setTab] = useState<Tab>('invoices');
  const [establishments, setEstablishments] = useState<Establishment[]>([]);

  const inputClass =
    'w-full bg-zinc-950 border border-zinc-700 rounded-lg px-3 py-2 text-white text-sm focus:border-yellow-500 focus:outline-none';

  // ── Load establishments once ──
  useEffect(() => {
    (async () => {
      try {
        const res = await fetchEstablishments({ per_page: '200' });
        setEstablishments(res.items || []);
      } catch (e) {
        console.error(e);
        /* TODO: toast */
      }
    })();
  }, []);

  const tabBtnClass = (t: Tab) =>
    `px-4 py-2 font-semibold rounded-lg transition-colors text-sm ${
      tab === t
        ? 'bg-yellow-500 text-zinc-900'
        : 'bg-zinc-800 text-zinc-300 hover:bg-zinc-700'
    }`;

  return (
    <div className="p-6 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Financeiro</h1>
        <p className="text-sm text-zinc-400 mt-1">Faturas, cupons e programa de fidelidade.</p>
      </div>

      {/* Tab bar */}
      <div className="flex gap-2">
        <button className={tabBtnClass('invoices')} onClick={() => setTab('invoices')}>
          <Receipt className="w-4 h-4 inline-block mr-1.5 -mt-0.5" />
          Faturas
        </button>
        <button className={tabBtnClass('coupons')} onClick={() => setTab('coupons')}>
          <Tag className="w-4 h-4 inline-block mr-1.5 -mt-0.5" />
          Cupons
        </button>
        <button className={tabBtnClass('loyalty')} onClick={() => setTab('loyalty')}>
          <Star className="w-4 h-4 inline-block mr-1.5 -mt-0.5" />
          Fidelidade
        </button>
      </div>

      {tab === 'invoices' && (
        <InvoicesTab establishments={establishments} inputClass={inputClass} />
      )}
      {tab === 'coupons' && <CouponsTab inputClass={inputClass} />}
      {tab === 'loyalty' && (
        <LoyaltyTab establishments={establishments} inputClass={inputClass} />
      )}
    </div>
  );
}
