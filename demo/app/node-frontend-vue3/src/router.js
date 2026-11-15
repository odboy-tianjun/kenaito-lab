import { createRouter, createWebHashHistory } from 'vue-router';
import Home from './views/HomeView.vue';

const routes = [
  { path: '/', name: 'home', component: Home },
  { path: '/form', name: 'form', component: () => import('./views/FormView.vue') },
  { path: '/about', name: 'about', component: () => import('./views/AboutView.vue') },
  // 前端路由兜底：hash 模式下用不到，Tengine 的 location / 里已经配了 try_files
  { path: '/:pathMatch(.*)*', redirect: '/' },
];

export default createRouter({
  history: createWebHashHistory(),
  routes,
});
