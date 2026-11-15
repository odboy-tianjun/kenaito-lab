import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

// 纯静态前端：产物由 Tengine 托管，base 用相对路径，部署到任意子路径都能跑
export default defineConfig({
  plugins: [vue()],
  base: './',
  server: {
    host: '0.0.0.0',
    port: 5473,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    rollupOptions: {
      output: {
        manualChunks: {
          vue: ['vue', 'vue-router'],
        },
      },
    },
  },
});
