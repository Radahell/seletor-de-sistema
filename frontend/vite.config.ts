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
      "/api": {
        // 👇 MUDE AQUI: De 'https' para 'http'
        target: "http://seletor-sistema-api:22012", 
        changeOrigin: true,
        secure: false,
      },
      "/uploads": {
        // 👇 MUDE AQUI TAMBÉM
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