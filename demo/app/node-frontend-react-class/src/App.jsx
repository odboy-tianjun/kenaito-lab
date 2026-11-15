import { Component } from 'react';
import Home from './views/Home.jsx';
import Form from './views/Form.jsx';
import About from './views/About.jsx';

const TABS = [
  { key: 'home', label: '首页', view: Home },
  { key: 'form', label: '表单', view: Form },
  { key: 'about', label: '关于', view: About },
];

// 类组件写法：用 this.state + this.setState 管理页签，等价于函数版的 useState
export default class App extends Component {
  constructor(props) {
    super(props);
    this.state = { active: 'home' };
    this.setActive = this.setActive.bind(this);
  }

  setActive(key) {
    this.setState({ active: key });
  }

  render() {
    const { active } = this.state;
    const Current = TABS.find((t) => t.key === active).view;

    return (
      <div className="app">
        <header className="header">
          <span className="logo">node-frontend-react-class</span>
          <nav className="nav">
            {TABS.map((t) => (
              <button
                key={t.key}
                type="button"
                className={t.key === active ? 'nav-item active' : 'nav-item'}
                onClick={() => this.setActive(t.key)}
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
}
