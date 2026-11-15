import { Component, version as reactVersion } from 'react';

function format(d) {
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`;
}

// 类组件：状态放 this.state，用 componentDidMount / componentWillUnmount 管理定时器
export default class Home extends Component {
  constructor(props) {
    super(props);
    this.state = {
      count: 0,
      clock: format(new Date()),
      keyword: '',
    };
    this.timer = null;
  }

  componentDidMount() {
    this.timer = setInterval(() => {
      this.setState({ clock: format(new Date()) });
    }, 1000);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
    this.timer = null;
  }

  render() {
    const { count, clock, keyword } = this.state;
    return (
      <>
        <div className="grid">
          <div className="card">
            <h3 className="card-title">运行时</h3>
            <table className="kv">
              <tbody>
                <tr><th>React</th><td>{reactVersion}</td></tr>
                <tr><th>写法</th><td>class（继承 Component）</td></tr>
                <tr><th>路由</th><td>示例用 this.state 页签，不引入路由库</td></tr>
              </tbody>
            </table>
          </div>

          <div className="card">
            <h3 className="card-title">计数器（this.state）</h3>
            <p className="clock">{count}</p>
            <button type="button" className="btn" onClick={() => this.setState((s) => ({ count: s.count - 1 }))}>-1</button>{' '}
            <button type="button" className="btn primary" onClick={() => this.setState((s) => ({ count: s.count + 1 }))}>+1</button>{' '}
            <button type="button" className="btn" onClick={() => this.setState({ count: 0 })}>重置</button>
          </div>

          <div className="card">
            <h3 className="card-title">当前时间（componentDidMount）</h3>
            <p className="clock">{clock}</p>
            <span className="hint">前端本地时间，不请求后端</span>
          </div>
        </div>

        <div className="card">
          <h3 className="card-title">受控输入</h3>
          <div className="field">
            <label htmlFor="kw">关键字</label>
            <input
              id="kw"
              value={keyword}
              onChange={(e) => this.setState({ keyword: e.target.value })}
              placeholder="输入关键字过滤，纯前端"
            />
          </div>
          {keyword && <div className="hint">已输入：{keyword}</div>}
        </div>
      </>
    );
  }
}
