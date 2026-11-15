import Vue from 'vue';
import VueRouter from 'vue-router';
import Home from './views/Home.vue';

Vue.use(VueRouter);

const routes = [
  { path: '/', name: 'home', component: Home },
  { path: '/form', name: 'form', component: () => import('./views/Form.vue') },
  { path: '/about', name: 'about', component: () => import('./views/About.vue') },
  // 前端路由兜底：放在 Tengine 上时，需要 location / 里 try_files $uri $uri/ /index.html
  { path: '*', redirect: '/' },
];

export default new VueRouter({
  mode: 'hash',
  routes,
});
