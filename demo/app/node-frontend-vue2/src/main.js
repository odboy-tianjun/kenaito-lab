import Vue from 'vue';
import ElementUI from 'element-ui';
import 'element-ui/lib/theme-chalk/index.css';
import './styles.css';

import App from './App.vue';
import router from './router';

// Vue 2.7 内置组合式 API，但示例保持 Vue 2 选项式写法，贴近 Element UI 2 的文档
Vue.use(ElementUI);
Vue.config.productionTip = false;

new Vue({
  router,
  render: (h) => h(App),
}).$mount('#app');
