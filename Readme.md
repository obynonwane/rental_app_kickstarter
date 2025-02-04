// The repo loads the .env and the .env.{ENVIRONMENT} and it load the specif env file based on teh value
// of DEV_ENV in the .env file, if DEV_ENV=test it load .env.test and use the environments there
// it loads both .env and .env.{ENVIRONMENT} but it runs the content of the environment specified in the
// DEV_ENV but if DEV_ENV is empty or local it load the .env environments instead
