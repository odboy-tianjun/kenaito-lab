import { Component } from 'react';

// 静态说明页：类组件写法，无状态
export default class About extends Component {
  render() {
    return (
      <div className="card">
        <h3 className="card-title">关于</h3>
        <table className="kv">
          <tbody>
            <tr><th>框架</th><td>React 19.3.1（class 组件）</td></tr>
            <tr><th>写法</th><td>继承 Component，状态在 this.state，生命周期用 componentDidMount/WillUnmount</td></tr>
            <tr><th>构建</th><td>Vite 7 + @vitejs/plugin-react 5</td></tr>
            <tr><th>部署</th><td>Tengine 3.1.0（proxy-tengine3 镜像）托管 dist/</td></tr>
          </tbody>
        </table>
      </div>
    );
  }
}
