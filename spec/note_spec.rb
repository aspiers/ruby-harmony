p require 'note'
puts "wtf"
#p Note
# describe Note do
#   shared_examples "a note" do |name, letter, pitch, accidental|
#     it "should have the right letter (#{letter})" do
#       note.letter.should == letter
#     end
# 
#     it "should have the right pitch (#{pitch})" do
#       note.pitch.should == pitch
#     end
#     
#     it "should have the right name (#{name})" do
#       note.name == name
#     end
#     
#     it "should have the right accidental (#{accidental})" do
#       note.accidental.should == accidental
#     end
#   end
# 
#   context "constructing #by_letter" do
#     context "A" do
#       let(:note) { Note.by_letter('A') }
#       it_should_behave_like "a note", "A", "A", 9, 0
#     end
# 
#     context "invalid letter" do
#       it "should return nil when given an invalid letter" do
#         Note.by_letter('H').should be_nil
#       end
#     end
#   end
# 
#   NOTES = [
#     [ "Gx",   9, +2 ],
#     [ "A",    9,  0 ],
#     [ "Bbb",  9, -2 ],
#              
#     [ "A#",  10,  1 ],
#     [ "Bb",  10, -1 ],
#     [ "Cbb", 10, -2 ],
#              
#     [ "Ax",  11, +2 ],
#     [ "B",   11,  0 ],
#     [ "Cb",  11, -1 ],
#              
#     [ "B#",   0, +1 ],
#     [ "C",    0,  0 ],
#     [ "Dbb",  0, -2 ],
#              
#     [ "Bx",   1, +2 ],
#     [ "C#",   1, +1 ],
#     [ "Db",   1, -1 ],
#              
#     [ "Cx",   2, +2 ],
#     [ "D",    2,  0 ],
#     [ "Ebb",  2, -2 ],
#              
#     [ "Dx",   4, +2 ],
#     [ "Fb",   4, -1 ],
#   ]
# 
#   context "constructing #by_letter_and_pitch" do
#     shared_examples "a note by letter and pitch" do |name, pitch, accidental|
#       let(:note) { Note.by_letter_and_pitch(name[0], pitch) }
#       it_should_behave_like "a note", name, name[0], pitch, accidental
#     end
# 
#     NOTES.each do |name, pitch, accidental|
#       it_should_behave_like "a note by letter and pitch", name, pitch, accidental
#     end
# 
#     context "invalid input" do
#       it "should raise error with invalid letter" do
#         lambda { Note.by_letter_and_pitch('H', 0) }.should \
#           raise_error(RuntimeError, /no such note with letter/)
#       end
# 
#       shared_examples "pitch mismatch" do |letter, pitch|
#         it "should raise error with pitch #{pitch} for #{letter}" do
#           lambda { Note.by_letter_and_pitch(letter, pitch) }.should \
#             raise_error(RuntimeError, /pitch mismatch for letter/)
#         end
#       end
# 
#       it_should_behave_like "pitch mismatch", 'A', 6
#       it_should_behave_like "pitch mismatch", 'A', 0
#       it_should_behave_like "pitch mismatch", 'B', 8
#       it_should_behave_like "pitch mismatch", 'B', 2
#       it_should_behave_like "pitch mismatch", 'C', 9
#       it_should_behave_like "pitch mismatch", 'C', 3
#     end
#   end
# 
#   context "constructing #by_name" do
#     shared_examples "a note by name" do |name, pitch, accidental|
#       let(:note) { Note.by_name(name) }
#       it_should_behave_like "a note", name, name[0], pitch, accidental
#     end
# 
#     NOTES.each do |name, pitch, accidental|
#       it_should_behave_like "a note by name", name, pitch, accidental
#     end
#   end
# 
#   context "#letter_shift" do
#     it "should shift 0 letters" do
#       Note.letter_shift('B', 0).should == 'B'
#     end
# 
#     context "no wrap" do
#       it "should shift up 1 letter" do
#         Note.letter_shift('B', 1).should == 'C'
#       end
#       it "should shift down 1 letter" do
#         Note.letter_shift('C', -1).should == 'B'
#       end
#       it "should shift up 4 letters" do
#         Note.letter_shift('D', 4).should == 'A'
#       end
#     end
# 
#     context "wrap" do
#       it "should shift down 1 letter and wrap" do
#         Note.letter_shift('A', -1).should == 'G'
#       end
#       it "should shift up 4 letters and wrap" do
#         Note.letter_shift('B', 4).should == 'F'
#       end
#     end
#   end
# end
