#!/bin/bash
cd "$(dirname "$0")"

# Para o servidor anterior se estiver rodando
pkill -f 'python3 -m http.server 8000' 2>/dev/null

# Inicia o servidor em background
python3 -m http.server 8000 > /dev/null 2>&1 &

# Espera um pouco e abre o navegador
sleep 1
xdg-open http://localhost:8000/login.html 2>/dev/null

echo "✅ Servidor iniciado!"
echo "🌐 Abrindo no navegador: http://localhost:8000/login.html"
echo ""
echo "💡 Para parar: pkill -f 'python3 -m http.server'"

