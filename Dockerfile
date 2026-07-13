# Custom images always start from a "base" image, via "FROM"
FROM mcr.microsoft.com/playwright:v1.39.0-jammy
# Run commands during the build process so that all tools are avialabel when later running the image.
RUN npm install -g netlify-cli@20.1.1 serve
# Installing jq /(parsing tool) using regular Linux package manager instead of node.
RUN apt update && apt install jq -y