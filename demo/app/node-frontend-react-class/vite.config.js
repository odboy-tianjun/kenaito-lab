import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// 纯静态前端：产物由 Tengine 托管，base 用相对路径，部署到任意子路径都能跑
export default defineConfig({
  plugins: [react()],
  base: './',
  server: {
    host: '0.0.0.0',
    port: 5573,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          react: ['react', 'react-dom'],
        },
      },
    },
  },
});
