# Dockerfile for nextjs app
FROM node:lts as builder

# Create app directory
WORKDIR /usr/src/app

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

# Install app dependencies
RUN npm install --loglevel verbose --maxsockets --fetch-retries 20

# Bundle app source
COPY . .

# Creates a "dist" folder with the production build
RUN npm run build

FROM nginx:alpine

# Copy the production build from the builder stage
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl --fail http://localhost:80 || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
