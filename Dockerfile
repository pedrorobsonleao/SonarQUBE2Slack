### Gerar a imagem de produção
FROM mcr.microsoft.com/powershell:lts-alpine-3.9

# Definir o diretório da aplicação.
# USER app
WORKDIR /app

# Copiar o resultado do build.
COPY . ./

# Definir o entrypoint.
ENTRYPOINT ["pwsh","./Main.ps1"]