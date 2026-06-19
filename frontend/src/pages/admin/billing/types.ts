/* ═══════════════════════════════════════════════════════════════════════════
   BILLING SHARED TYPES
   ═══════════════════════════════════════════════════════════════════════════ */

export interface Invoice {
  id: number;
  establishment_id: number;
  establishment_name?: string;
  amount: number;
  status: string;
  due_date?: string;
  reference_period?: string;
  description?: string;
  created_at?: string;
  [key: string]: unknown;
}

export interface Payment {
  id: number;
  amount: number;
  method?: string;
  paid_at?: string;
  [key: string]: unknown;
}

export interface Coupon {
  id: number;
  code: string;
  discount_type: string;
  discount_value: number;
  max_usages: number;
  current_usages?: number;
  expires_at?: string;
  is_active: boolean;
  description?: string;
  [key: string]: unknown;
}

export interface LoyaltyEntry {
  id: number;
  type: string;
  points: number;
  reason?: string;
  created_at?: string;
  [key: string]: unknown;
}
