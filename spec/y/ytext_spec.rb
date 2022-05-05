# frozen_string_literal: true

RSpec.describe Y::Text do
  context "when creating text type" do
    it "create text with name" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")
      text.push(transaction, "name")

      expect(text.to_s).to eq("name")
    end
  end

  context "when introspecting text" do
    it "returns length of text" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")
      text.push(transaction, "hello")

      expect(text.length).to eq("hello".length)
    end
  end

  context "when updating text" do
    it "pushes to the end" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")
      text.push(transaction, "hello")
      text.push(transaction, "world")

      expect(text.to_s).to eq("helloworld")
    end

    it "insert at position" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")
      text.push(transaction, "abd")
      text.insert(transaction, 2, "c")

      expect(text.to_s).to eq("abcd")
    end

    it "insert embed" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")

      content = 123
      text.insert_embed(transaction, 2, content)

      expect(text.to_s).to eq("")
    end

    it "insert embed with attributes" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")

      content = 123
      attrs = { format: "bold" }
      text.insert_embed_with_attrs(transaction, 2, content, attrs)

      expect(text.to_s).to eq("")
    end

    it "insert with attributes" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")

      attrs = { format: "bold" }
      text.insert_with_attrs(transaction, 2, "hello", attrs)

      expect(text.to_s).to eq("hello")
    end

    it "formats with attributes" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")
      text.push(transaction, "hello")

      attrs = { format: "bold" }
      text.format(transaction, 2, 2, attrs)

      expect(text.to_s).to eq("hello")
    end
  end

  context "when removing text" do
    it "removes range starting at position" do
      doc = Y::Doc.new
      transaction = doc.transact
      text = transaction.get_text("name")
      text.push(transaction, "hello")
      text.push(transaction, "world")
      text.remove_range(transaction, 5, 4)

      expect(text.to_s).to eq("hellod")
    end
  end

  context "when introspecting changes" do
    it "returns changes" do
      local_doc = Y::Doc.new
      local_txn1 = local_doc.transact
      local_text = local_txn1.get_text("name")

      remote_doc = Y::Doc.new

      remote_txn1 = remote_doc.transact
      remote_text = remote_txn1.get_text("name")
      remote_text.insert_with_attrs(remote_txn1, 0, "Hello", { format: "bold" })

      local_state_vector = local_doc.state_vector
      update = remote_doc.encode_diff_v1(local_state_vector)
      pp local_text.changes(local_txn1, update)

      remote_txn2 = remote_doc.transact
      remote_text = remote_txn2.get_text("name")
      remote_text.insert(remote_txn2, 5, ", World!", {})

      local_txn2 = local_doc.transact
      local_state_vector = local_doc.state_vector
      update = remote_doc.encode_diff_v1(local_state_vector)

      pp local_text.changes(local_txn2, update)
    end
  end
end
