// 静态说明页，无逻辑
export default function About() {
  return (
    <div className="card">
      <h3 className="card-title">关于</h3>
      <table className="kv">
        <tbody>
          <tr><th>框架</th><td>React 19.3.1（函数组件 + Hooks）</td></tr>
          <tr><th>构建</th><td>Vite 7 + @vitejs/plugin-react 5</td></tr>
          <tr><th>部署</th><td>Tengine 3.1.0（proxy-tengine3 镜像）托管 dist/</td></tr>
          <tr><th>页签</th><td>useState 控制，不引入 react-router；需要路由时自行添加</td></tr>
        </tbody>
      </table>
    </div>
  );
}
