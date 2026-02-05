import { useEffect } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';

// New centralized auth system
import { AuthProvider } from './contexts/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import AuthPage from './pages/AuthPage';
import DashboardPage from './pages/DashboardPage';
import ProfilePage from './pages/ProfilePage';
import DiscoverPage from './pages/DiscoverPage';
import LancesPage from './pages/LancesPage';

// Legacy routes (can be removed later)
import SystemSelectPage from './pages/SystemSelectPage';
import TenantSelectBySystemPage from './pages/TenantSelectBySystemPage';
import LoginPage from './pages/LoginPage';
import { SuperAdmin } from './pages/SuperAdmin';

type TenantTheme = {
  primaryColor?: string;
  secondaryColor?: string;
  accentColor?: string;
  backgroundColor?: string;
};

function applyTheme(theme: TenantTheme | null) {
  if (!theme) return;
  const root = document.documentElement;
  if (theme.primaryColor) root.style.setProperty('--tenant-primary', theme.primaryColor);
  if (theme.secondaryColor) root.style.setProperty('--tenant-secondary', theme.secondaryColor);
  if (theme.accentColor) root.style.setProperty('--tenant-accent', theme.accentColor);
  if (theme.backgroundColor) root.style.setProperty('--tenant-bg', theme.backgroundColor);
}

export default function App() {
  useEffect(() => {
    const raw = localStorage.getItem('tenant_theme');
    if (!raw) return;
    try {
      applyTheme(JSON.parse(raw));
    } catch {
      // ignore
    }
  }, []);

  return (
    <AuthProvider>
      <Routes>
        {/* New centralized auth routes */}
        <Route path="/auth" element={<AuthPage />} />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <DashboardPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/profile"
          element={
            <ProtectedRoute>
              <ProfilePage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/discover/:slug"
          element={<DiscoverPage />}
        />
        <Route
          path="/lances"
          element={
            <ProtectedRoute>
              <LancesPage />
            </ProtectedRoute>
          }
        />

        {/* Legacy routes - redirect root to new auth */}
        <Route path="/" element={<Navigate to="/auth" replace />} />

        {/* Legacy routes (for backwards compatibility) */}
        <Route path="/legacy" element={<SystemSelectPage />} />
        <Route path="/select-tenant/:systemSlug" element={<TenantSelectBySystemPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/super-admin" element={<SuperAdmin />} />

        {/* Catch-all redirect */}
        <Route path="*" element={<Navigate to="/auth" replace />} />
      </Routes>
    </AuthProvider>
  );
}
