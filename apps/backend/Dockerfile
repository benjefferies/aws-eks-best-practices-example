# Dockerfile for nestjs app
FROM node:lts

# Create a new user for the container
RUN adduser --disabled-password --gecos "" nodeuser

# Set the user for the container
USER nodeuser

# Create app directory
WORKDIR /usr/src/app

# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

# Install app dependencies
RUN npm install

# Bundle app source
COPY . .

# Creates a "dist" folder with the production build
RUN npm run build

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl --fail http://localhost:3000/health || exit 1

# Start the server using the production build
CMD [ "node", "dist/main.js" ]