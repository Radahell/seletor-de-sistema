import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ArrowLeft, Users, MapPin, Phone, Mail, Plus, Loader2, Check, Clock,
  Trophy, Video, Building2, Flag
} from 'lucide-react';
import api, { TenantDetails, ApiError } from '../services/api';
import { useAuth } from '../contexts/AuthContext';

const SYSTEM_ICONS: Record<string, typeof Trophy> = {
  jogador: Trophy,
  lances: Video,
  quadra: Building2,
  arbitro: Flag,
};

export default function DiscoverPage() {
  const navigate = useNavigate();
  const { slug } = useParams<{ slug: string }>();
  const { isAuthenticated, refreshUser } = useAuth();

  const [tenant, setTenant] = useState<TenantDetails | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isJoining, setIsJoining] = useState(false);
  const [joinStatus, setJoinStatus] = useState<'idle' | 'success' | 'pending' | 'error'>('idle');
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState('');

  useEffect(() => {
    if (slug) {
      loadTenant();
    }
  }, [slug]);

  const loadTenant = async () => {
    setIsLoading(true);
    try {
      const response = await api.getTenantDetails(slug!);
      setTenant(response.tenant);
    } catch (err) {
      console.error('Error loading tenant:', err);
      setError('Sistema não encontrado');
    } finally {
      setIsLoading(false);
    }
  };

  const handleJoin = async () => {
    if (!isAuthenticated) {
      // Store intent and redirect to login
      localStorage.setItem('join_intent', slug!);
      navigate('/auth');
      return;
    }

    setIsJoining(true);
    setError(null);

    try {
      const response = await api.joinTenant(undefined, slug, message || undefined);

      if (response.status === 'pending') {
        setJoinStatus('pending');
      } else {
        setJoinStatus('success');
        await refreshUser();
      }
    } catch (err) {
      if (err instanceof ApiError) {
        if (err.status === 409) {
          setJoinStatus('success'); // Already a member
        } else {
          setError(err.message);
          setJoinStatus('error');
        }
      } else {
        setError('Erro ao processar. Tente novamente.');
        setJoinStatus('error');
      }
    } finally {
      setIsJoining(false);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-zinc-950 via-zinc-900 to-zinc-950 flex items-center justify-center">
        <Loader2 className="w-8 h-8 text-red-500 animate-spin" />
      </div>
    );
  }

  if (!tenant) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-zinc-950 via-zinc-900 to-zinc-950 px-4 py-12">
        <div className="max-w-lg mx-auto text-center">
          <h1 className="text-2xl font-bold text-white mb-4">Sistema não encontrado</h1>
          <button
            onClick={() => navigate('/dashboard')}
            className="text-red-400 hover:text-red-300"
          >
            Voltar ao Dashboard
          </button>
        </div>
      </div>
    );
  }

  const Icon = SYSTEM_ICONS[tenant.system?.slug || ''] || Trophy;

  return (
    <div className="min-h-screen bg-gradient-to-br from-zinc-950 via-zinc-900 to-zinc-950 px-4 py-8">
      <div className="max-w-2xl mx-auto">
        {/* Back button */}
        <button
          onClick={() => navigate(-1)}
          className="flex items-center gap-2 text-zinc-400 hover:text-white transition-colors mb-6"
        >
          <ArrowLeft className="w-5 h-5" />
          Voltar
        </button>

        {/* Header Card */}
        <div className="rounded-3xl border border-zinc-800 bg-zinc-900/50 overflow-hidden">
          {/* Banner */}
          <div
            className="h-32 relative"
            style={{ backgroundColor: tenant.primaryColor || '#ef4444' }}
          >
            <div className="absolute inset-0 bg-gradient-to-t from-zinc-900/80 to-transparent" />
          </div>

          {/* Content */}
          <div className="p-6 -mt-16 relative">
            {/* Logo */}
            <div
              className="w-24 h-24 rounded-2xl flex items-center justify-center text-3xl font-black text-white border-4 border-zinc-900 mb-4"
              style={{ backgroundColor: tenant.primaryColor || '#ef4444' }}
            >
              {tenant.logoUrl ? (
                <img src={tenant.logoUrl} alt="" className="w-full h-full object-cover rounded-xl" />
              ) : (
                tenant.displayName.charAt(0)
              )}
            </div>

            {/* System badge */}
            <div className="flex items-center gap-2 mb-2">
              <div
                className="w-6 h-6 rounded-md flex items-center justify-center"
                style={{ backgroundColor: (tenant.system?.color || '#666') + '30' }}
              >
                <Icon className="w-3 h-3" style={{ color: tenant.system?.color }} />
              </div>
              <span className="text-xs font-bold uppercase tracking-wider text-zinc-500">
                {tenant.system?.displayName}
              </span>
            </div>

            {/* Title */}
            <h1 className="text-2xl font-black text-white mb-2">
              {tenant.displayName}
            </h1>

            {/* Members */}
            <div className="flex items-center gap-2 text-zinc-400 text-sm mb-4">
              <Users className="w-4 h-4" />
              <span>{tenant.memberCount || 0} participantes</span>
            </div>

            {/* Description */}
            {tenant.welcomeMessage && (
              <p className="text-zinc-400 mb-6">
                {tenant.welcomeMessage}
              </p>
            )}

            {/* Contact info */}
            {(tenant.address || tenant.phone || tenant.email) && (
              <div className="space-y-2 mb-6 p-4 rounded-xl bg-zinc-800/50">
                {tenant.address && (
                  <div className="flex items-start gap-2 text-sm text-zinc-400">
                    <MapPin className="w-4 h-4 mt-0.5 flex-shrink-0" />
                    <span>{tenant.address}{tenant.city && ` - ${tenant.city}/${tenant.state}`}</span>
                  </div>
                )}
                {tenant.phone && (
                  <div className="flex items-center gap-2 text-sm text-zinc-400">
                    <Phone className="w-4 h-4" />
                    <span>{tenant.phone}</span>
                  </div>
                )}
                {tenant.email && (
                  <div className="flex items-center gap-2 text-sm text-zinc-400">
                    <Mail className="w-4 h-4" />
                    <span>{tenant.email}</span>
                  </div>
                )}
              </div>
            )}

            {/* Join section */}
            {joinStatus === 'idle' && (
              <>
                {!tenant.allowRegistration && (
                  <div className="mb-4">
                    <label className="block text-xs font-bold uppercase tracking-wider text-zinc-500 mb-2">
                      Mensagem (opcional)
                    </label>
                    <textarea
                      value={message}
                      onChange={(e) => setMessage(e.target.value)}
                      placeholder="Conte um pouco sobre você..."
                      rows={3}
                      className="w-full px-4 py-3 rounded-xl bg-zinc-800 border border-zinc-700 text-white placeholder-zinc-500 focus:border-red-500 focus:outline-none transition-colors resize-none"
                    />
                    <p className="text-xs text-zinc-500 mt-1">
                      Este sistema requer aprovação do administrador
                    </p>
                  </div>
                )}

                {error && (
                  <div className="mb-4 p-3 rounded-xl bg-red-500/10 border border-red-500/20 text-red-400 text-sm">
                    {error}
                  </div>
                )}

                <button
                  onClick={handleJoin}
                  disabled={isJoining}
                  className="w-full py-4 rounded-xl bg-gradient-to-r from-red-500 to-orange-500 text-white font-bold uppercase tracking-wider flex items-center justify-center gap-2 hover:from-red-600 hover:to-orange-600 transition-all disabled:opacity-50"
                >
                  {isJoining ? (
                    <Loader2 className="w-5 h-5 animate-spin" />
                  ) : (
                    <>
                      <Plus className="w-5 h-5" />
                      {isAuthenticated ? 'Participar' : 'Fazer Login para Participar'}
                    </>
                  )}
                </button>
              </>
            )}

            {joinStatus === 'success' && (
              <div className="text-center py-4">
                <div className="w-16 h-16 rounded-full bg-green-500/20 flex items-center justify-center mx-auto mb-4">
                  <Check className="w-8 h-8 text-green-500" />
                </div>
                <h3 className="text-lg font-bold text-white mb-2">
                  Você entrou!
                </h3>
                <p className="text-zinc-400 text-sm mb-4">
                  Agora você faz parte do {tenant.displayName}
                </p>
                <button
                  onClick={() => navigate('/dashboard')}
                  className="px-6 py-3 rounded-xl bg-zinc-800 text-white font-bold hover:bg-zinc-700 transition-colors"
                >
                  Ir para o Dashboard
                </button>
              </div>
            )}

            {joinStatus === 'pending' && (
              <div className="text-center py-4">
                <div className="w-16 h-16 rounded-full bg-yellow-500/20 flex items-center justify-center mx-auto mb-4">
                  <Clock className="w-8 h-8 text-yellow-500" />
                </div>
                <h3 className="text-lg font-bold text-white mb-2">
                  Solicitação Enviada!
                </h3>
                <p className="text-zinc-400 text-sm mb-4">
                  Aguarde a aprovação do administrador
                </p>
                <button
                  onClick={() => navigate('/dashboard')}
                  className="px-6 py-3 rounded-xl bg-zinc-800 text-white font-bold hover:bg-zinc-700 transition-colors"
                >
                  Voltar ao Dashboard
                </button>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
