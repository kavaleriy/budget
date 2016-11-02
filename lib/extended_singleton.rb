# class ExtendedSingleton
#   # class CustomArray
#     def self.add_singleton_arr_to_f!(obj)
#       unless obj.kind_of?(Array)
#         raise('Need only array obj')
#       end
#       obj.define_singleton_method(:all_to_f!) do
#         self.each_with_index do |val, index|
#           if self[index].kind_of?(Array)
#             self.all_to_f!
#             # self[index].all_to_f!
#           else
#             self[index] = val.to_f
#           end
#         end
#       end
#     end
#   # end
#
# end