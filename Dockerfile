# Base image for running the app
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

# Set environment variable to bind to port 5000
ENV ASPNETCORE_URLS=http://+:5000

# User is already set to 'app' in the base image, so no need to add it manually
USER app

# Build stage: SDK image
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["AZ2003.csproj", "./"]
RUN dotnet restore "AZ2003.csproj"
COPY . . 
WORKDIR "/src/."
RUN dotnet build "AZ2003.csproj" -c $configuration -o /app/build

# Publish stage
FROM build AS publish
ARG configuration=Release
RUN dotnet publish "AZ2003.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

# Final stage: base image for running the app
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "AZ2003.dll"]
