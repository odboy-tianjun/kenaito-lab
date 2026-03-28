var builder = WebApplication.CreateBuilder(args);

// 容器内监听 8081，避免与宿主机其它 80 端口冲突；可用环境变量 ASPNETCORE_URLS 覆盖
builder.WebHost.UseUrls(Environment.GetEnvironmentVariable("ASPNETCORE_URLS") ?? "http://0.0.0.0:8081");

var app = builder.Build();

app.MapGet("/", () => Results.Json(new
{
    message = "dotnet8 is running",
    runtime = Environment.Version.ToString(),
    os = System.Runtime.InteropServices.RuntimeInformation.OSDescription,
    time = DateTimeOffset.Now.ToString("yyyy-MM-dd HH:mm:ss zzz")
}));

app.MapGet("/health", () => Results.Ok("ok"));

app.Run();
