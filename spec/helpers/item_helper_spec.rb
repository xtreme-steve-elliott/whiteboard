require 'spec_helper'

describe "ItemHelper" do
  describe "#date_label" do
    describe "when there is not a date" do
      let(:item) { create(:item, kind: "Help") }

      it "returns nothing" do
        label = helper.date_label(item)
        label.should be_blank
      end
    end

    describe "when there is a date" do
      describe "when passed an Event" do
        it "displays day of week" do
          event = create(:item, kind: "Event", date: Date.new(2012, 11, 05))
          label = helper.date_label(event)
          label.should == "Monday: "
        end
      end

      describe "when passed an Item that is not an Event" do
        let(:item) { create(:item, kind: "Help") }

        describe "when the date is <= today" do
          before do
            item.date = Date.yesterday
          end

          it "returns nothing" do
            label = helper.date_label(item)
            label.should be_blank
          end
        end

        describe "when the date is in the future" do
          before do
            Date.stub(today: Date.new(2012, 11, 04))
            item.date = Date.new(2012, 11, 06)
          end

          it "returns the day of the week" do
            label = helper.date_label(item)
            label.should == "Tuesday: "
          end
        end
      end
    end
  end
end
