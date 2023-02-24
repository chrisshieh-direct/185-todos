require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = PG.connect(dbname: "185_todo")
    @logger = logger
  end

  def query(statement, *params)
    @logger.info("#{statement}: params are #{params}")
    @db.exec_params(statement, params)
  end

  def find_list(id)
    tuple = query("SELECT * FROM lists WHERE list_id = $1", id).first
    retrieved = retrieve_todos(id)
    {id: tuple["list_id"], name: tuple["name"], todos: retrieved}
  end

  def all_lists
    query("SELECT * FROM lists").map do |tuple|
      {id: tuple["list_id"], name: tuple["name"], todos: retrieve_todos(tuple["list_id"])}
    end
  end

  def add_list(name)
    query("INSERT INTO lists (name) VALUES ($1);", name)
  end

  def delete_list(id)
    query("DELETE FROM lists WHERE list_id = $1", id)
  end

  def update_list_name(id, new_name)
    query("UPDATE lists SET name = $1 WHERE list_id = $2", new_name, id)
  end

  def add_todo(list_id, todo_name)
    query("INSERT INTO todos (list_id, name) VALUES ($1, $2)", list_id, todo_name)
  end

  def delete_todo(list_id, todo_id)
    query("DELETE FROM todos WHERE list_id = $1 AND todo_id = $2", list_id, todo_id)
  end

  def update_todo_status(list_id, todo_id, new_status)
    query("UPDATE todos SET completed = $1 WHERE todo_id = $2 AND list_id = $3", new_status, todo_id, list_id)
  end

  def mark_all_todos_complete(list_id)
    query("UPDATE todos SET completed = true WHERE list_id = $1", list_id)
  end

  private

  def retrieve_todos(list_id)
    query("SELECT * from todos WHERE list_id = $1", list_id).map do |tuple|
      {id: tuple["todo_id"], name: tuple["name"], completed: tuple["completed"] == 't'}
    end
  end
end
