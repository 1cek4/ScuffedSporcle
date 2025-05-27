const express = require('express');
const bodyParser = require('body-parser');
const userRoutes = require('./userRoutes.js');
const connectDB = require('./mariadb.js');
const eurekaClient = require('./eureka');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(bodyParser.json());

// Routes
app.use('/users', userRoutes);

const startServer = async () => {
    try {
        await connectDB();
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
            eurekaClient.start((error) => {
                if (error) {
                    console.error('Eureka registration failed:', error);
                } else {
                    console.log('Registered with Eureka!');
                }
            });
        });
    } catch (err) {
        console.error('Failed to connect to DB, server not started.');
        process.exit(1);
    }
};

startServer();