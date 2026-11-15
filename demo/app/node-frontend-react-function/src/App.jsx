import { useState } from 'react';
import Home from './views/Home.jsx';
import Form from './views/Form.jsx';
import About from './views/About.jsx';

const TABS = [
  { key: 'home', label: '首页', view: Home },
  { key: 'form', label: '表单', view: Form },
  { key: 'about', label: '关于', view: About },
];

// 示例不引入路由库：用一个受控 state 当页签，保持依赖最少；真实项目可换 react-router
export default function App() {
  const [active, setActive] = useState('home');
  const Current = TABS.find((t) => t.key === active).view;

  return (
    <div className="app">
      <header className="header">
        <span className="logo">node-frontend-react-function</span>
        <nav className="nav">
          {TABS.map((t) => (
            <button
              key={t.key}
              type="button"
              className={t.key === active ? 'nav-item active' : 'nav-item'}
              onClick={() => setActive(t.key)}
            >
              {t.label}
            </button>
          ))}
        </nav>
      </header>
      <main className="main">
        <Current />
      </main>
    </div>
  );
}
