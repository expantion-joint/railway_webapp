# アプリケーションサーバの性能を決定する
worker_processes 2

# アプリケーションの設置されているディレクトリを指定
working_directory "/src"

# ポート番号を指定
listen "0.0.0.0:3000", tcp_nopush: true

# プロセスIDの保存先を指定
pid "/src/tmp/pids/unicorn.pid"

# エラーのログを記録するファイルを指定
stderr_path "/src/log/unicorn.stderr.log"

# 通常のログを記録するファイルを指定
stdout_path "/src/log/unicorn.stdout.log"

#応答時間を待つ上限時間を設定
timeout 30

# ダウンタイムなしでUnicornを再起動時する
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  # 古い PID ファイルを削除
  pidfile = "/src/tmp/pids/unicorn.pid"
  File.delete(pidfile) if File.exist?(pidfile)

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end