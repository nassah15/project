# start with lightweight base image
FROM python:3.11-slim

# Set working directory for subsequent commands
WORKDIR /app

# copy dependencies into working directory
COPY requirements.txt ./ 

# Install dependencies without storing in cache dir
RUN pip install --no-cache-dir -r requirements.txt

# Copy src and rest of files that are not in .gitignore
COPY . .

# Tell Flask to run app in dev mode
ENV FLASK_APP=app.py

# What to run when container starts running
CMD ["flask", "run", "--host=0.0.0.0"]
