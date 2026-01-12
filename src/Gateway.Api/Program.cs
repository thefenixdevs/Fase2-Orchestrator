using Microsoft.OpenApi;

var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Add HttpClientFactory for Swagger aggregation
builder.Services.AddHttpClient();

// Configure YARP Reverse Proxy
builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

// Configure Swagger with multiple API definitions
builder.Services.AddSwaggerGen(options =>
{
    // Users API
    options.SwaggerDoc("users-api", new OpenApiInfo
    {
        Title = "Users API",
        Version = "v1",
        Description = "API de Gerenciamento de Usuários - FIAP"
    });

    // Catalog API
    options.SwaggerDoc("catalog-api", new OpenApiInfo
    {
        Title = "Catalog API",
        Version = "v1",
        Description = "API de Catálogo de Jogos - FIAP"
    });

    // Payments API
    options.SwaggerDoc("payments-api", new OpenApiInfo
    {
        Title = "Payments API",
        Version = "v1",
        Description = "API de Pagamentos - FIAP"
    });

    // Notifications API
    options.SwaggerDoc("notifications-api", new OpenApiInfo
    {
        Title = "Notifications API",
        Version = "v1",
        Description = "API de Notificações - FIAP"
    });

    // Add Bearer Token authentication
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        Description = "JWT Authorization header using the Bearer scheme."
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
// IMPORTANTE: Swagger deve ser configurado ANTES do proxy reverso
// para que as rotas do Swagger não sejam interceptadas pelo proxy

// Health check endpoint (mapear antes do proxy)
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", service = "Gateway API" }));

// Enable Swagger in all environments for K8s
app.UseSwagger();
app.UseSwaggerUI(options =>
{
    // Users API Swagger (served locally by SwaggerController)
    options.SwaggerEndpoint("/swagger/users/v1/swagger.json", "Users API v1");
    
    // Catalog API Swagger (served locally by SwaggerController)
    options.SwaggerEndpoint("/swagger/games/v1/swagger.json", "Catalog API v1");
    
    // Payments API Swagger (served locally by SwaggerController)
    options.SwaggerEndpoint("/swagger/payments/v1/swagger.json", "Payments API v1");
    
    // Notifications API Swagger (served locally by SwaggerController)
    options.SwaggerEndpoint("/swagger/notifications/v1/swagger.json", "Notifications API v1");
    
    options.RoutePrefix = string.Empty; // Swagger na raiz (/)
    
    // Configurações para melhorar a experiência do Swagger UI
    options.EnableDeepLinking(); // Permite links diretos para endpoints
    options.DisplayRequestDuration(); // Mostra o tempo de requisição
});

// Map reverse proxy (deve vir DEPOIS do Swagger para não interceptar as rotas do Swagger)
app.MapReverseProxy();

app.MapControllers();

app.Run();

public partial class Program { }
