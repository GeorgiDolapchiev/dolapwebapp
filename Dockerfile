FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 5291

ENV ASPNETCORE_URLS=http://+:5291

USER app
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["dolapwebapp/dolapwebapp.csproj", "dolapwebapp/"]
RUN dotnet restore "dolapwebapp/dolapwebapp.csproj"
COPY . .
WORKDIR "/src/dolapwebapp"
RUN dotnet build "dolapwebapp.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "dolapwebapp.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dolapwebapp.dll"]
