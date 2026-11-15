import { useEffect, useState } from 'react';
import { version as reactVersion } from 'react';

function format(d) {
  const p = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}:${p(d.getSeconds())}`;
}

// 纯前端展示：所有数据都在浏览器里产生，不调用任何后端接口
export default function Home() {
  const [count, setCount] = useState(0);
  const [clock, setClock] = useState(() => format(new Date()));
  const [keyword, setKeyword] = useState('');

  useEffect(() => {
    const timer = setInterval(() => setClock(format(new Date())), 1000);
    return () => clearInterval(timer);
  }, []);

  return (
    <>
      <div className="grid">
        <div className="card">
          <h3 className="card-title">运行时</h3>
          <table className="kv">
            <tbody>
              <tr><th>React</th><td>{reactVersion}</td></tr>
              <tr><th>构建</th><td>Vite 7 + @vitejs/plugin-react</td></tr>
              <tr><th>路由</th><td>示例用 useState 页签，不引入路由库</td></tr>
            </tbody>
          </table>
        </div>

        <div className="card">
          <h3 className="card-title">计数器（useState）</h3>
          <p className="clock">{count}</p>
          <button type="button" className="btn" onClick={() => setCount((c) => c - 1)}>-1</button>{' '}
          <button type="button" className="btn primary" onClick={() => setCount((c) => c + 1)}>+1</button>{' '}
          <button type="button" className="btn" onClick={() => setCount(0)}>重置</button>
        </div>

        <div className="card">
          <h3 className="card-title">当前时间（useEffect）</h3>
          <p className="clock">{clock}</p>
          <span className="hint">前端本地时间，不请求后端</span>
        </div>
      </div>

      <div className="card">
        <h3 className="card-title">受控输入</h3>
        <div className="field">
          <label htmlFor="kw">关键字</label>
          <input id="kw" value={keyword} onChange={(e) => setKeyword(e.target.value)} placeholder="输入关键字过滤，纯前端" />
        </div>
        {keyword && <div className="hint">已输入：{keyword}</div>}
      </div>
    </>
  );
}
