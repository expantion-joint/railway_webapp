class ActiveStorageCleanJob < ApplicationJob
  queue_as :default

  def perform
    unattached_blobs = ActiveStorage::Blob.left_outer_joins(:attachments)
                                           .where(active_storage_attachments: { id: nil })

    deleted_file_names = []

    unattached_blobs.find_each do |blob|
      begin
        deleted_file_names << blob.filename.to_s
        blob.purge_later
      rescue => e
        Rails.logger.error("削除失敗: #{blob.id} - #{e.message}")
      end
    end

    # 通知を送信（削除ファイルがあるときのみ）
    if deleted_file_names.any?
      ActiveStorageCleanMailer.deleted_files_report(deleted_file_names).deliver_later
    end
  end
end

  