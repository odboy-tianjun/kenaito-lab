import { createApp } from 'vue';
import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';
import './styles.css';

import App from './App.vue';
import router from './router';

// Vue 3 组合式写法 + Element Plus
createApp(App).use(router).use(ElementPlus).mount('#app');
