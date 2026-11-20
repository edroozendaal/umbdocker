FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
ARG CI=false
ENV BUILD_CONFIGURATION=$BUILD_CONFIGURATION
ENV CI=$CI
WORKDIR /src
COPY . .

WORKDIR "/src/src/UmbDocker"

RUN dotnet publish "UmbDocker.csproj" \
	-c $BUILD_CONFIGURATION \
	-o /app/publish \
	/p:UseAppHost=false \
	/p:CopyContentFilesToFolder=true \
	/p:CopyOutputsToPublishDirectory=true \
	--force

FROM base AS final
WORKDIR /app
COPY --from=build --chown=$APP_UID:$APP_UID /app/publish .

ENV ASPNETCORE_ENVIRONMENT=Production \
    ASPNETCORE_URLS=http://+:8080

# Run as the unprivileged user built into the .NET images (not root)
USER $APP_UID
ENTRYPOINT ["dotnet", "UmbDocker.dll"]
