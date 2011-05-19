#
# upsert
# 
Mongo::Collection.class_eval do
  def upsert! query, opt
    # opt.size.must == 1
    # opt.must_be.a Hash
    # opt.values.first.must_be.a Hash
    
    update(query, opt, {upsert: true, safe: true})
  end
end