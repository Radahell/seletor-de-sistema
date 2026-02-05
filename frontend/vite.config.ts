import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

export default defineConfig({
  base: "/",
  plugins: [react()],
  server: {
    host: "0.0.0.0",
    port: 22011,
    strictPort: true,
    allowedHosts: ["varzeaprime.com.br", "www.varzeaprime.com.br"],
    proxy: {
      // Seletor API — mesmo path que o nginx usa em produção
      "/seletor-api": {
        target: "http://seletor-sistema-api:22012",
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/seletor-api/, ""),
      },
      // SCL API — mesmo path que o nginx usa em produção
      "/scl-api": {
        target: "http://scl:6000",
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/scl-api/, ""),
      },
      "/uploads": {
        target: "http://seletor-sistema-api:22012",
        changeOrigin: true,
        secure: false,
      },
    },
    hmr: {
      protocol: "wss",
      host: "varzeaprime.com.br",
      clientPort: 443,
    },
  },
});
