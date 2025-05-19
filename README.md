# 📚 Project Name
GameSwap is a rental platform where users can lend and borrow games from each other. Lenders can list their games, and borrowers can send rental requests. Once accepted, they can message each other through the app. The platform also allows borrowers to leave reviews after the rental is complete, promoting a trustworthy community.

App home: https://game-swap-e551a983a6f1.herokuapp.com/

## Getting Started
### Setup

Install gems
```
bundle install
```

### ENV Variables
Create `.env` file
```
touch .env
```
Inside `.env`, set these variables. For any APIs, see group Slack channel.
```
CLOUDINARY_URL=your_own_cloudinary_url_key
```

### DB Setup
```
rails db:create
rails db:migrate
rails db:seed
```

### Run a server
```
rails s
```

## Built With
- [Rails 7](https://guides.rubyonrails.org/) - Backend / Front-end
- [Stimulus JS](https://stimulus.hotwired.dev/) - Front-end JS
- [Heroku](https://heroku.com/) - Deployment
- [PostgreSQL](https://www.postgresql.org/) - Database
- [Bootstrap](https://getbootstrap.com/) — Styling
- [Figma](https://www.figma.com) — Prototyping

## Team Members
- [Alex Wong](https://github.com/Munkleson)
- [Allan Sechrist](https://github.com/AllanSechrist)
- [Minami Takayama](https://github.com/minami-77)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
