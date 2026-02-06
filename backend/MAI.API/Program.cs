using Microsoft.EntityFrameworkCore;
using MAI.API.Data;
using MAI.API.Services; // Добавь эту строку!

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Регистрируем GeminiService с HttpClient
builder.Services.AddHttpClient<GeminiService>(); // HttpClient
builder.Services.AddScoped<GeminiService>();     // Сам сервис!

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();