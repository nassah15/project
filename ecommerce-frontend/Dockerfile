# start with lightweight base image
FROM node:20-alpine

# Set working directory for subsequent commands
WORKDIR /app

# copy dependencies into working directory
COPY package*.json ./

# Install react
RUN npm install

# Copy src and rest of files that are not in .gitignore
COPY . .

# To build assets
RUN npm run build

EXPOSE 5173

# Run the vite dev server
CMD ["npm", "run", "dev", "--", "--host"]
