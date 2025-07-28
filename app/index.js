const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.urlencoded({ extended: true }));

// Connect to MongoDB
const MONGO_URI = 'mongodb://192.168.56.10:27017/todoApp';
mongoose.connect(MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });

const Todo = mongoose.model('Todo', { text: String });

app.get('/', async (req, res) => {
  const todos = await Todo.find().sort({ _id: -1 });
  res.send(
    <html>
      <head>
        <title>TODO App</title>
        <style>
          body { font-family: sans-serif; padding: 2em; max-width: 600px; margin: auto; }
          form { margin-bottom: 1em; }
          input[type="text"] { width: 70%; padding: 0.5em; }
          input[type="submit"] { padding: 0.5em; }
          ul { padding: 0; list-style: none; }
          li { background: #eee; margin: 0.5em 0; padding: 0.5em; display: flex; justify-content: space-between; }
          form.delete { display: inline; margin: 0; }
          button { background: red; color: white; border: none; padding: 0.3em 0.6em; cursor: pointer; }
        </style>
      </head>
      <body>
        <h1>Simple TODO App</h1>
        <form method="POST" action="/add">
          <input type="text" name="text" placeholder="New TODO" required />
          <input type="submit" value="Add" />
        </form>
        <ul>
          ${todos.map(todo => 
            <li>
              ${todo.text}
              <form class="delete" method="POST" action="/delete/${todo._id}">
                <button type="submit">X</button>
              </form>
            </li>
          ).join('')}
        </ul>
      </body>
    </html>
  );
});

app.post('/add', async (req, res) => {
  const { text } = req.body;
  if (text) await Todo.create({ text });
  res.redirect('/');
});

app.post('/delete/:id', async (req, res) => {
  await Todo.findByIdAndDelete(req.params.id);
  res.redirect('/');
});

app.listen(3000, () => {
  console.log('TODO app running at http://localhost:3000');
});