import {
  ArrowLeft,
  Camera,
  ChevronRight,
  Clock,
  Download,
  ExternalLink,
  Eye,
  Film,
  Loader2,
  Play,
  RefreshCw,
  Smartphone,
  Trash2,
  Video,
  Wifi,
  X
} from 'lucide-react';
import { useCallback, useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import SwitchSystemMenu from '../components/SwitchSystemMenu';
import { useAuth } from '../contexts/AuthContext';

const SCL_API = import.meta.env.VITE_SCL_API_URL || '/scl-api';

interface ClipInfo {
  id: string;
  session_id: string;
  mode: string;
  status: string;
  created_at: string;
  total_duration_seconds: number;
  thumbnail_path?: string;
  resolution?: string;
}

interface RecordingInfo {
  id: string;
  session_id: string;
  game_id: string;
  status: string;
  cameras: string[];
  started_at?: string;
  ended_at?: string;
  total_duration_seconds?: number;
  thumbnail_path?: string;
}

interface SessionInfo {
  id: string;
  device_name: string;
  channel: string;
  started_at: string;
  total_bytes: number;
  tenant_id?: string;
  user_id?: number;
  mode: string;
  uptime_seconds: number;
}

type TabType = 'live' | 'clips' | 'recordings';

async function sclFetch<T>(endpoint: string, token: string): Promise<T> {
  const response = await fetch(`${SCL_API}${endpoint}`, {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
  });
  if (!response.ok) {
    const data = await response.json().catch(() => ({}));
    throw new Error(data.detail || 'Erro ao buscar dados');
  }
  return response.json();
}

// ─── Auto Thumbnail Generator via Canvas ─────────────────────────────────
function useVideoThumbnail(videoUrl: string | null, seekTime = 3) {
  const [thumbnail, setThumbnail] = useState<string | null>(null);

  useEffect(() => {
    if (!videoUrl) return;
    let cancelled = false;

    const video = document.createElement('video');
    video.crossOrigin = 'anonymous';
    video.muted = true;
    video.preload = 'metadata';
    video.src = videoUrl;

    const capture = () => {
      if (cancelled) return;
      const canvas = document.createElement('canvas');
      canvas.width = video.videoWidth || 320;
      canvas.height = video.videoHeight || 180;
      const ctx = canvas.getContext('2d');
      if (ctx) {
        ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
        try {
          setThumbnail(canvas.toDataURL('image/jpeg', 0.8));
        } catch {
          // CORS issue — silently fail
        }
      }
      video.pause();
      video.src = '';
    };

    video.addEventListener('seeked', capture, { once: true });
    video.addEventListener('loadedmetadata', () => {
      video.currentTime = Math.min(seekTime, video.duration * 0.1 || seekTime);
    }, { once: true });

    video.load();

    return () => {
      cancelled = true;
      video.src = '';
    };
  }, [videoUrl, seekTime]);

  return thumbnail;
}

// ─── Video Preview Hook ────────────────────────────────────────────────────
function useVideoPreview(clipId: string, token: string | null) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [isHovered, setIsHovered] = useState(false);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const fetchPreviewUrl = useCallback(async () => {
    if (!token || previewUrl) return;
    try {
      const data = await sclFetch<{ url: string }>(
        `/api/athlete/clips/${clipId}/stream`, token
      );
      setPreviewUrl(data.url);
    } catch {
      // silently fail
    }
  }, [clipId, token, previewUrl]);

  const handleMouseEnter = useCallback(() => {
    setIsHovered(true);
    fetchPreviewUrl();
  }, [fetchPreviewUrl]);

  const handleMouseLeave = useCallback(() => {
    setIsHovered(false);
    if (videoRef.current) {
      videoRef.current.pause();
      videoRef.current.currentTime = 0;
    }
    if (timerRef.current) clearTimeout(timerRef.current);
  }, []);

  useEffect(() => {
    if (isHovered && previewUrl && videoRef.current) {
      videoRef.current.currentTime = 0;
      videoRef.current.play().catch(() => {});
      timerRef.current = setTimeout(() => {
        if (videoRef.current) {
          videoRef.current.pause();
          videoRef.current.currentTime = 0;
        }
      }, 5000);
    }
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  }, [isHovered, previewUrl]);

  return { videoRef, previewUrl, isHovered, handleMouseEnter, handleMouseLeave };
}

// ─── Clip Card ─────────────────────────────────────────────────────────────
function ClipCard({
  clip,
  token,
  onStream,
  onDownload,
  onDelete,
  getStatusColor,
  getStatusLabel,
  formatDuration,
  formatDate,
}: {
  clip: ClipInfo;
  token: string | null;
  onStream: (id: string) => void;
  onDownload: (id: string) => void;
  onDelete: (id: string) => void;
  getStatusColor: (s: string) => string;
  getStatusLabel: (s: string) => string;
  formatDuration: (s: number) => string;
  formatDate: (s?: string) => string;
}) {
  const { videoRef, previewUrl, isHovered, handleMouseEnter, handleMouseLeave } =
    useVideoPreview(clip.id, token);

  // Gera thumbnail automaticamente a partir do vídeo quando não há thumbnail_path
  const autoThumbnail = useVideoThumbnail(
    !clip.thumbnail_path && clip.status === 'ready' ? previewUrl : null
  );

  const thumbnailSrc = clip.thumbnail_path
    ? `${SCL_API}${clip.thumbnail_path}`
    : autoThumbnail;

  return (
    <div
      className="group rounded-2xl border border-white/5 bg-white/3 overflow-hidden hover:border-purple-500/30 transition-all duration-300 hover:shadow-[0_0_30px_rgba(168,85,247,0.08)] hover:-translate-y-0.5"
      style={{ background: 'rgba(255,255,255,0.02)' }}
    >
      {/* Thumbnail / Preview */}
      <div
        className="aspect-video bg-zinc-900 relative flex items-center justify-center overflow-hidden cursor-pointer"
        onMouseEnter={handleMouseEnter}
        onMouseLeave={handleMouseLeave}
        onClick={() => clip.status === 'ready' && onStream(clip.id)}
      >
        {/* Thumbnail (estática ou gerada automaticamente) */}
        {thumbnailSrc ? (
          <img
            src={thumbnailSrc}
            alt=""
            className={`absolute inset-0 w-full h-full object-cover transition-opacity duration-300 ${isHovered && previewUrl ? 'opacity-0' : 'opacity-100'}`}
          />
        ) : (
          <div className={`absolute inset-0 flex items-center justify-center transition-opacity duration-300 ${isHovered && previewUrl ? 'opacity-0' : 'opacity-100'}`}>
            <Film className="w-10 h-10 text-zinc-700" />
          </div>
        )}

        {/* Video Preview */}
        {previewUrl && (
          <video
            ref={videoRef}
            src={previewUrl}
            muted
            playsInline
            className={`absolute inset-0 w-full h-full object-cover transition-opacity duration-300 ${isHovered ? 'opacity-100' : 'opacity-0'}`}
          />
        )}

        {/* Hover overlay gradient */}
        <div className={`absolute inset-0 bg-gradient-to-t from-black/80 via-transparent to-transparent transition-opacity duration-300 ${isHovered ? 'opacity-100' : 'opacity-0'}`} />

        {/* Play icon centered */}
        {clip.status === 'ready' && (
          <div className={`absolute inset-0 flex items-center justify-center transition-all duration-300 ${isHovered ? 'opacity-100 scale-100' : 'opacity-0 scale-90'}`}>
            <div className="w-12 h-12 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center border border-white/30">
              <Play className="w-5 h-5 text-white ml-0.5" />
            </div>
          </div>
        )}

        {/* Preview badge */}
        {isHovered && previewUrl && (
          <div className="absolute top-2 left-2 px-2 py-0.5 rounded-md bg-black/70 backdrop-blur-sm text-white text-[10px] font-bold tracking-widest uppercase border border-white/10">
            Prévia 5s
          </div>
        )}

        {/* Duration */}
        <div className="absolute bottom-2 right-2 px-2 py-0.5 rounded-md bg-black/70 backdrop-blur-sm text-white text-xs font-mono border border-white/10">
          {formatDuration(clip.total_duration_seconds)}
        </div>
      </div>

      {/* Info */}
      <div className="p-4">
        <div className="flex items-center justify-between mb-2">
          <span className={`text-[10px] font-bold uppercase tracking-widest px-2 py-0.5 rounded-md ${getStatusColor(clip.status)}`}>
            {getStatusLabel(clip.status)}
          </span>
          <span className="text-[10px] text-zinc-600 uppercase tracking-wider font-medium">{clip.mode}</span>
        </div>

        <p className="text-sm text-zinc-400 font-medium">{formatDate(clip.created_at)}</p>

        {clip.resolution && (
          <p className="text-[10px] text-zinc-600 mt-0.5 font-mono">{clip.resolution}</p>
        )}

        {/* Actions */}
        <div className="flex gap-2 mt-4">
          {clip.status === 'ready' && (
            <>
              <button
                onClick={() => onStream(clip.id)}
                className="flex-1 py-2 rounded-xl bg-purple-500/10 text-purple-400 text-xs font-bold hover:bg-purple-500/20 transition-colors flex items-center justify-center gap-1.5 border border-purple-500/10 hover:border-purple-500/20"
              >
                <Eye className="w-3.5 h-3.5" />
                Assistir
              </button>
              <button
                onClick={() => onDownload(clip.id)}
                className="flex-1 py-2 rounded-xl bg-white/3 text-zinc-400 text-xs font-bold hover:bg-white/6 transition-colors flex items-center justify-center gap-1.5 border border-white/5 hover:border-white/10"
                style={{ background: 'rgba(255,255,255,0.03)' }}
              >
                <Download className="w-3.5 h-3.5" />
                Baixar
              </button>
            </>
          )}
          <button
            onClick={() => onDelete(clip.id)}
            className="py-2 px-3 rounded-xl bg-red-500/5 text-red-500/60 text-xs font-bold hover:bg-red-500/10 hover:text-red-400 transition-colors flex items-center justify-center border border-red-500/10 hover:border-red-500/20"
            title="Excluir"
          >
            <Trash2 className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── Recording Card ────────────────────────────────────────────────────────
function RecordingCard({
  rec,
  token,
  getStatusColor,
  getStatusLabel,
  formatDuration,
  formatDate,
  onError,
}: {
  rec: RecordingInfo;
  token: string | null;
  getStatusColor: (s: string) => string;
  getStatusLabel: (s: string) => string;
  formatDuration: (s: number) => string;
  formatDate: (s?: string) => string;
  onError: (msg: string) => void;
}) {
  const [streamUrl, setStreamUrl] = useState<string | null>(null);

  // Busca a URL de stream para gerar thumbnail automaticamente
  useEffect(() => {
    if (!token || rec.thumbnail_path || rec.status !== 'ready') return;
    sclFetch<{ url: string }>(`/api/athlete/recordings/${rec.id}/stream`, token)
      .then(d => setStreamUrl(d.url))
      .catch(() => {});
  }, [rec.id, rec.status, rec.thumbnail_path, token]);

  const autoThumbnail = useVideoThumbnail(streamUrl);

  const thumbnailSrc = rec.thumbnail_path
    ? `${SCL_API}${rec.thumbnail_path}`
    : autoThumbnail;

  const handleStream = async () => {
    if (!token) return;
    try {
      const data = await sclFetch<{ url: string }>(`/api/athlete/recordings/${rec.id}/stream`, token);
      window.open(data.url, '_blank');
    } catch (err: any) {
      onError(err.message || 'Erro ao abrir gravação');
    }
  };

  const handleDownload = async () => {
    if (!token) return;
    try {
      const data = await sclFetch<{ url: string; filename: string }>(`/api/athlete/recordings/${rec.id}/download`, token);
      const a = document.createElement('a');
      a.href = data.url;
      a.download = data.filename;
      a.click();
    } catch (err: any) {
      onError(err.message || 'Erro ao baixar gravação');
    }
  };

  return (
    <div
      className="rounded-2xl border border-white/5 overflow-hidden hover:border-purple-500/20 transition-all group"
      style={{ background: 'rgba(255,255,255,0.02)' }}
    >
      <div className="flex items-stretch">
        {/* Thumbnail */}
        <div className="w-36 sm:w-44 flex-shrink-0 bg-zinc-900 relative overflow-hidden">
          {thumbnailSrc ? (
            <img
              src={thumbnailSrc}
              alt=""
              className="w-full h-full object-cover opacity-80 group-hover:opacity-100 transition-opacity"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center min-h-[80px]">
              <Video className="w-8 h-8 text-zinc-700" />
            </div>
          )}
          {rec.status === 'recording' && (
            <div className="absolute top-2 left-2 flex items-center gap-1 px-1.5 py-0.5 rounded-md bg-red-500/90 text-white text-[10px] font-bold">
              <div className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
              REC
            </div>
          )}
        </div>

        {/* Info */}
        <div className="flex-1 p-4 flex flex-col justify-between min-w-0">
          <div>
            <div className="flex items-center gap-2 mb-2 flex-wrap">
              <span className={`text-[10px] font-bold uppercase tracking-widest px-2 py-0.5 rounded-md ${getStatusColor(rec.status)}`}>
                {getStatusLabel(rec.status)}
              </span>
              <span className="text-[10px] text-zinc-600 font-medium">
                {rec.cameras.length} câmera{rec.cameras.length > 1 ? 's' : ''}
              </span>
            </div>
            <p className="text-sm text-white font-semibold truncate">
              Gravação de {formatDate(rec.started_at)}
            </p>
            <div className="flex items-center gap-3 mt-1.5 text-xs text-zinc-600 flex-wrap">
              {rec.total_duration_seconds && (
                <span className="flex items-center gap-1">
                  <Clock className="w-3 h-3" />
                  {formatDuration(rec.total_duration_seconds)}
                </span>
              )}
              {rec.ended_at && (
                <span>Término: {formatDate(rec.ended_at)}</span>
              )}
              {rec.cameras.length > 0 && (
                <span className="text-zinc-700">{rec.cameras.slice(0, 2).join(', ')}{rec.cameras.length > 2 ? ` +${rec.cameras.length - 2}` : ''}</span>
              )}
            </div>
          </div>

          {rec.status === 'ready' && (
            <div className="flex gap-2 mt-3">
              <button
                onClick={handleStream}
                className="py-1.5 px-3 rounded-xl bg-purple-500/10 text-purple-400 text-xs font-bold hover:bg-purple-500/20 transition-colors flex items-center gap-1.5 border border-purple-500/10"
              >
                <Play className="w-3 h-3" />
                Assistir
              </button>
              <button
                onClick={handleDownload}
                className="py-1.5 px-3 rounded-xl text-zinc-400 text-xs font-bold hover:text-white transition-colors flex items-center gap-1.5 border border-white/5 hover:border-white/10"
                style={{ background: 'rgba(255,255,255,0.03)' }}
              >
                <Download className="w-3 h-3" />
                Baixar
              </button>
            </div>
          )}
        </div>

        {/* Arrow */}
        <div className="flex items-center pr-4 text-zinc-700 group-hover:text-zinc-500 transition-colors">
          <ChevronRight className="w-4 h-4" />
        </div>
      </div>
    </div>
  );
}

// ─── Main Page ─────────────────────────────────────────────────────────────
export default function LancesPage() {
  const navigate = useNavigate();
  const { user, tenants } = useAuth();

  const [activeTab, setActiveTab] = useState<TabType>('clips');
  const [clips, setClips] = useState<ClipInfo[]>([]);
  const [recordings, setRecordings] = useState<RecordingInfo[]>([]);
  const [sessions, setSessions] = useState<SessionInfo[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const token = localStorage.getItem('auth_token');
  const currentTenant = tenants.find(t => t.system?.slug === 'lances') || null;

  useEffect(() => { loadData(); }, [activeTab]);

  const loadData = async () => {
    if (!token) return;
    setIsLoading(true);
    setError(null);
    try {
      if (activeTab === 'clips') {
        const data = await sclFetch<{ clips: ClipInfo[]; total: number }>('/api/athlete/clips?limit=50', token);
        setClips(data.clips);
      } else if (activeTab === 'recordings') {
        const data = await sclFetch<{ recordings: RecordingInfo[]; total: number }>('/api/athlete/recordings?limit=50', token);
        setRecordings(data.recordings);
      } else if (activeTab === 'live') {
        try {
          const data = await sclFetch<SessionInfo[]>('/api/athlete/sessions', token);
          setSessions(Array.isArray(data) ? data : []);
        } catch { setSessions([]); }
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar dados');
    } finally {
      setIsLoading(false);
    }
  };

  const formatDuration = (seconds: number) => {
    const m = Math.floor(seconds / 60);
    const s = seconds % 60;
    return `${m}:${s.toString().padStart(2, '0')}`;
  };

  const formatDate = (dateStr?: string) => {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleDateString('pt-BR', {
      day: '2-digit', month: '2-digit', year: '2-digit',
      hour: '2-digit', minute: '2-digit',
    });
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'ready': case 'synced': return 'text-emerald-400 bg-emerald-500/10 border border-emerald-500/20';
      case 'pending': case 'extracting': case 'encoding': case 'processing': return 'text-amber-400 bg-amber-500/10 border border-amber-500/20';
      case 'failed': return 'text-red-400 bg-red-500/10 border border-red-500/20';
      case 'recording': return 'text-red-400 bg-red-500/10 border border-red-500/20 animate-pulse';
      default: return 'text-zinc-400 bg-zinc-500/10 border border-zinc-500/20';
    }
  };

  const getStatusLabel = (status: string) => {
    const labels: Record<string, string> = {
      ready: 'Pronto', synced: 'Sincronizado', pending: 'Pendente',
      extracting: 'Extraindo', encoding: 'Codificando', processing: 'Processando',
      failed: 'Erro', recording: 'Gravando', scheduled: 'Agendado', deleted: 'Removido',
    };
    return labels[status] || status;
  };

  const handleStreamClip = async (clipId: string) => {
    if (!token) return;
    try {
      const data = await sclFetch<{ url: string }>(`/api/athlete/clips/${clipId}/stream`, token);
      window.open(data.url, '_blank');
    } catch (err: any) { setError(err.message); }
  };

  const handleDownloadClip = async (clipId: string) => {
    if (!token) return;
    try {
      const data = await sclFetch<{ url: string; filename: string }>(`/api/athlete/clips/${clipId}/download`, token);
      const a = document.createElement('a');
      a.href = data.url; a.download = data.filename; a.click();
    } catch (err: any) { setError(err.message); }
  };

  const handleDeleteClip = async (clipId: string) => {
    if (!token) return;
    if (!window.confirm('Excluir este lance permanentemente?')) return;
    try {
      const resp = await fetch(`${SCL_API}/api/athlete/clips/${clipId}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}`, 'Content-Type': 'application/json' },
      });
      if (!resp.ok) {
        const data = await resp.json().catch(() => ({}));
        throw new Error(data.detail || 'Erro ao excluir');
      }
      setClips(prev => prev.filter(c => c.id !== clipId));
    } catch (err: any) { setError(err.message || 'Erro ao excluir lance'); }
  };

  const tabs: { key: TabType; label: string; icon: typeof Video; count?: number }[] = [
    { key: 'clips', label: 'Meus Lances', icon: Film, count: clips.length || undefined },
    { key: 'recordings', label: 'Gravações', icon: Video, count: recordings.length || undefined },
    { key: 'live', label: 'Ao Vivo', icon: Wifi, count: sessions.length || undefined },
  ];

  return (
    <div className="min-h-screen" style={{ background: 'linear-gradient(135deg, #0a0a0f 0%, #0d0d14 50%, #0a0a0f 100%)' }}>
      <div className="fixed inset-0 pointer-events-none opacity-30" style={{
        backgroundImage: `url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='0.4'/%3E%3C/svg%3E")`,
        backgroundSize: '150px',
      }} />

      <div className="fixed top-0 left-1/2 -translate-x-1/2 w-[600px] h-[300px] pointer-events-none"
        style={{ background: 'radial-gradient(ellipse at center top, rgba(139,92,246,0.06) 0%, transparent 70%)' }} />

      <header className="sticky top-0 z-40 border-b border-white/5 backdrop-blur-xl" style={{ background: 'rgba(10,10,15,0.85)' }}>
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate('/dashboard')}
              className="p-2 rounded-xl text-zinc-500 hover:text-white hover:bg-white/5 transition-all"
            >
              <ArrowLeft className="w-4 h-4" />
            </button>
            <div className="flex items-center gap-3">
              <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background: 'linear-gradient(135deg, #7c3aed, #6d28d9)' }}>
                <Video className="w-4 h-4 text-white" />
              </div>
              <div>
                <h1 className="text-base font-bold text-white leading-tight">Meus Lances</h1>
                <p className="text-[11px] text-zinc-600">Vídeos e transmissões</p>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2">
            <button
              onClick={loadData}
              disabled={isLoading}
              className="p-2 rounded-xl text-zinc-500 hover:text-white hover:bg-white/5 transition-all disabled:opacity-40"
              title="Atualizar"
            >
              <RefreshCw className={`w-4 h-4 ${isLoading ? 'animate-spin' : ''}`} />
            </button>
            <SwitchSystemMenu currentTenant={currentTenant} />
          </div>
        </div>
      </header>

      <div className="max-w-6xl mx-auto px-4 pt-6 space-y-4">
        <a
          href={token ? `${SCL_API}/camera/?hub_token=${encodeURIComponent(token)}` : '#'}
          target="_blank"
          rel="noopener noreferrer"
          className={`flex items-center gap-3 p-3.5 rounded-2xl no-underline transition-all group border border-emerald-500/20 hover:border-emerald-400/40 ${!token ? 'opacity-50 pointer-events-none' : ''}`}
          style={{ background: 'linear-gradient(135deg, rgba(16,185,129,0.08), rgba(5,150,105,0.05))' }}
        >
          <div className="w-10 h-10 rounded-xl bg-emerald-500/15 flex items-center justify-center border border-emerald-500/20 flex-shrink-0">
            <Smartphone className="w-5 h-5 text-emerald-400" />
          </div>
          <div className="flex-1">
            <p className="text-white font-semibold text-sm leading-tight">Usar Celular como Câmera</p>
            <p className="text-emerald-500/70 text-xs mt-0.5">Toque para iniciar sua câmera pessoal</p>
          </div>
          <ExternalLink className="w-4 h-4 text-emerald-500/40 group-hover:text-emerald-400 transition-colors" />
        </a>

        <div className="flex gap-1 p-1 rounded-2xl border border-white/5" style={{ background: 'rgba(255,255,255,0.02)' }}>
          {tabs.map(tab => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.key;
            return (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`flex-1 py-2.5 rounded-xl font-bold text-xs uppercase tracking-widest transition-all flex items-center justify-center gap-2 ${
                  isActive ? 'text-white' : 'text-zinc-600 hover:text-zinc-400'
                }`}
                style={isActive ? { background: 'linear-gradient(135deg, #7c3aed, #6d28d9)', boxShadow: '0 2px 16px rgba(124,58,237,0.3)' } : {}}
              >
                <Icon className="w-3.5 h-3.5" />
                <span className="hidden sm:inline">{tab.label}</span>
                {tab.count !== undefined && tab.count > 0 && (
                  <span className={`text-[10px] px-1.5 py-0.5 rounded-md font-mono ${isActive ? 'bg-white/20 text-white' : 'bg-white/5 text-zinc-500'}`}>
                    {tab.count}
                  </span>
                )}
              </button>
            );
          })}
        </div>
      </div>

      <main className="max-w-6xl mx-auto px-4 py-6">
        {error && (
          <div className="mb-6 p-4 rounded-2xl border border-red-500/20 text-red-400 text-sm flex items-center justify-between" style={{ background: 'rgba(239,68,68,0.05)' }}>
            <span>{error}</span>
            <button onClick={() => setError(null)}>
              <X className="w-4 h-4 opacity-60 hover:opacity-100" />
            </button>
          </div>
        )}

        {isLoading ? (
          <div className="flex flex-col items-center justify-center py-24 gap-4">
            <div className="w-14 h-14 rounded-2xl flex items-center justify-center border border-purple-500/20" style={{ background: 'rgba(124,58,237,0.08)' }}>
              <Loader2 className="w-6 h-6 text-purple-400 animate-spin" />
            </div>
            <p className="text-zinc-600 text-sm">Carregando...</p>
          </div>
        ) : (
          <>
            {activeTab === 'clips' && (
              clips.length === 0 ? (
                <EmptyState icon={Film} title="Nenhum lance encontrado" description="Seus lances aparecerão aqui quando forem capturados durante os jogos" />
              ) : (
                <div>
                  <p className="text-xs text-zinc-600 mb-4 font-medium uppercase tracking-widest">
                    {clips.length} {clips.length === 1 ? 'lance' : 'lances'} — passe o mouse para ver a prévia
                  </p>
                  <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                    {clips.map(clip => (
                      <ClipCard
                        key={clip.id}
                        clip={clip}
                        token={token}
                        onStream={handleStreamClip}
                        onDownload={handleDownloadClip}
                        onDelete={handleDeleteClip}
                        getStatusColor={getStatusColor}
                        getStatusLabel={getStatusLabel}
                        formatDuration={formatDuration}
                        formatDate={formatDate}
                      />
                    ))}
                  </div>
                </div>
              )
            )}

            {activeTab === 'recordings' && (
              recordings.length === 0 ? (
                <EmptyState icon={Video} title="Nenhuma gravação encontrada" description="Gravações completas dos seus jogos aparecerão aqui" />
              ) : (
                <div className="space-y-3">
                  {recordings.map(rec => (
                    <RecordingCard
                      key={rec.id}
                      rec={rec}
                      token={token}
                      getStatusColor={getStatusColor}
                      getStatusLabel={getStatusLabel}
                      formatDuration={formatDuration}
                      formatDate={formatDate}
                      onError={setError}
                    />
                  ))}
                </div>
              )
            )}

            {activeTab === 'live' && (
              sessions.length === 0 ? (
                <EmptyState icon={Wifi} title="Nenhuma transmissão ao vivo" description="Quando uma câmera estiver ativa na sua quadra durante seu horário, a transmissão aparecerá aqui" />
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  {sessions.map(session => (
                    <div key={session.id} className="rounded-2xl border border-white/5 overflow-hidden hover:border-red-500/20 transition-all" style={{ background: 'rgba(255,255,255,0.02)' }}>
                      <div className="aspect-video bg-zinc-900 relative flex items-center justify-center">
                        <Camera className="w-16 h-16 text-zinc-800" />
                        <div className="absolute inset-0 flex items-center justify-center">
                          <div className="w-24 h-24 rounded-full bg-red-500/5 animate-ping" />
                        </div>
                        <div className="absolute top-3 left-3 flex items-center gap-1.5 px-2.5 py-1 rounded-xl bg-red-500 text-white text-xs font-bold shadow-lg shadow-red-500/30">
                          <div className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
                          AO VIVO
                        </div>
                      </div>
                      <div className="p-4">
                        <h3 className="font-bold text-white text-sm">{(session as any).field_name || session.device_name || 'Sessão ao vivo'}</h3>
                        <p className="text-xs text-zinc-600 mt-1">
                          {((session as any).cameras_connected ?? 0)} câmera{((session as any).cameras_connected ?? 0) !== 1 ? 's' : ''} · Desde {formatDate(session.started_at)}
                        </p>
                        <a
                          href={`${SCL_API}/viewer/?session=${session.id}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="mt-3 w-full py-2.5 rounded-xl text-white font-bold text-sm flex items-center justify-center gap-2 no-underline transition-all border border-red-500/30 hover:border-red-400/50"
                          style={{ background: 'linear-gradient(135deg, #ef4444, #dc2626)', boxShadow: '0 4px 20px rgba(239,68,68,0.2)' }}
                        >
                          <Play className="w-4 h-4" />
                          Assistir Ao Vivo
                        </a>
                      </div>
                    </div>
                  ))}
                </div>
              )
            )}
          </>
        )}
      </main>
    </div>
  );
}

function EmptyState({ icon: Icon, title, description }: { icon: typeof Video; title: string; description: string }) {
  return (
    <div className="text-center py-24">
      <div className="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-5 border border-white/5" style={{ background: 'rgba(255,255,255,0.03)' }}>
        <Icon className="w-7 h-7 text-zinc-700" />
      </div>
      <h3 className="text-base font-bold text-white mb-2">{title}</h3>
      <p className="text-zinc-600 text-sm max-w-sm mx-auto leading-relaxed">{description}</p>
    </div>
  );
}