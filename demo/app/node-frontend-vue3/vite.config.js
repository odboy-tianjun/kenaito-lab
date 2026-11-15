import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

// 纯静态前端：产物由 Tengine 托管，base 用相对路径，部署到任意子路径都能跑
export default defineConfig({
  plugins: [vue()],
  base: './',
  server: {
    host: '0.0.0.0',
    port: 5273,
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    // element-plus 体积较大，单独拆包，利用浏览器缓存
    rollupOptions: {
      output: {
        manualChunks: {
          'element-plus': ['element-plus'],
          vue: ['vue', 'vue-router'],
        },
      },
    },
  },
});
