# Use the official .NET SDK image for build
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out

# Use the official ASP.NET runtime image for run
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS runtime
WORKDIR /app
COPY --from=build /app/out ./

# Expose port 80
EXPOSE 80

# Start the application
ENTRYPOINT ["dotnet", "TechBit.Net.Bd.dll"]