FactoryGirl.define do
  factory :question do
    caption "What is the answer to this question?"
    page
    
    factory :radio_field, class: "Questions::RadioField" do
    end

    factory :text_field, class: "Questions::TextField" do
    end

    factory :big_text_field, class: "Questions::BigTextField" do
    end

    factory :drop_down_field, class: "Questions::DropDownField" do
    end

    factory :range_field, class: "Questions::RangeField" do
      min 1
      max 5
    end

    factory :check_box_field, class: "Questions::CheckBoxField" do
    end

    factory :heading, class: "Questions::Heading" do
    end

    factory :label, class: "Questions::Label" do
    end

    factory :divider, class: "Questions::Divider" do
    end
  end
end