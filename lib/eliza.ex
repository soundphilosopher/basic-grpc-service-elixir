defmodule Eliza do
  @moduledoc """
  ELIZA - A classic chatbot implementation in Elixir.

  ELIZA was one of the first chatbots, created by Joseph Weizenbaum at MIT in the 1960s.
  This implementation simulates a Rogerian psychotherapist using pattern matching
  and simple transformations.
  """

  # Transformation rules for pronouns and common words
  @transformations %{
    "i" => "you",
    "me" => "you",
    "my" => "your",
    "mine" => "yours",
    "you" => "I",
    "your" => "my",
    "yours" => "mine",
    "am" => "are",
    "are" => "am",
    "was" => "were",
    "were" => "was",
    "i'm" => "you are",
    "you're" => "I am"
  }

  # Pattern matching rules with responses
  @rules [
    # Greetings
    {~r/hello|hi|hey/i, :greeting,
     [
       "Hello there. How are you feeling today?",
       "Hi. What brings you here today?",
       "Hello. Please tell me what's on your mind."
     ]},

    # Goodbyes - marked with :goodbye type
    {~r/bye|goodbye|farewell|quit|exit|end/i, :goodbye,
     [
       "Goodbye. I hope our conversation was helpful.",
       "Farewell. Take care of yourself.",
       "Goodbye. Feel free to come back anytime.",
       "It was nice talking with you. Goodbye!",
       "Take care. Our session is now ending."
     ]},

    # Feelings and emotions
    {~r/i feel (.+)/i, :emotion,
     [
       "Why do you feel {1}?",
       "How long have you felt {1}?",
       "What makes you feel {1}?"
     ]},
    {~r/i am (.+)/i, :emotion,
     [
       "Why are you {1}?",
       "How does being {1} make you feel?",
       "What led you to be {1}?"
     ]},

    # Family relationships
    {~r/my (.+) (mother|father|mom|dad|parent)/i, :family,
     [
       "Tell me more about your {2}.",
       "How is your relationship with your {2}?",
       "What role does your {2} play in this?"
     ]},
    {~r/my (mother|father|mom|dad|parent) (.+)/i, :family,
     [
       "Your {1} {2}?",
       "Tell me more about your {1}.",
       "How do you feel about your {1}?"
     ]},

    # Questions about ELIZA
    {~r/who are you|what are you/i, :meta,
     [
       "I am ELIZA, a computer program. How does that make you feel?",
       "Why do you ask about me? Let's talk about you.",
       "I'm here to listen. What would you like to discuss?"
     ]},

    # Dreams
    {~r/i dream|i dreamed|i dreamt (.+)/i, :dreams,
     [
       "Dreams can be very meaningful. What do you think this dream means?",
       "How did this dream make you feel?",
       "What comes to mind when you think about this dream?"
     ]},

    # Problems and troubles
    {~r/i have (.+) problem/i, :problems,
     [
       "How long have you had this problem with {1}?",
       "What do you think causes this problem?",
       "How does this problem affect you?"
     ]},
    {~r/i can't (.+)/i, :inability,
     [
       "Why can't you {1}?",
       "What would happen if you could {1}?",
       "Have you tried to {1}?"
     ]},

    # Desires and wants
    {~r/i want (.+)/i, :desires,
     [
       "Why do you want {1}?",
       "What would getting {1} mean to you?",
       "How would you feel if you got {1}?"
     ]},
    {~r/i need (.+)/i, :needs,
     [
       "Why do you need {1}?",
       "What would happen if you didn't get {1}?",
       "How important is {1} to you?"
     ]},

    # Relationships
    {~r/(.+) reminds me of (.+)/i, :memory,
     [
       "What connection do you see between {1} and {2}?",
       "Why do you think {1} reminds you of {2}?",
       "Tell me more about {2}."
     ]},

    # Memory and recall
    {~r/i remember (.+)/i, :memory,
     [
       "What else do you remember about {1}?",
       "Why do you think you remember {1} now?",
       "How does remembering {1} make you feel?"
     ]},

    # Yes/No responses
    {~r/^yes$/i, :affirmation,
     [
       "I see. Can you tell me more?",
       "Why do you think so?",
       "What makes you so sure?"
     ]},
    {~r/^no$/i, :negation,
     [
       "Why not?",
       "You seem quite certain. Can you explain?",
       "What makes you say no?"
     ]},

    # Questions from user
    {~r/what (.+)\?/i, :question,
     [
       "Why do you ask about {1}?",
       "What do you think about {1}?",
       "Does {1} concern you?"
     ]},
    {~r/why (.+)\?/i, :question,
     [
       "Why do you think {1}?",
       "What's your opinion about {1}?",
       "Perhaps you can answer your own question about {1}."
     ]},

    # Computer/AI references
    {~r/computer|ai|artificial|robot/i, :technology,
     [
       "Do computers worry you?",
       "What do you think about machines?",
       "How do you feel about talking to a computer?"
     ]},

    # Always responses (catch-all patterns)
    {~r/always (.+)/i, :absolute,
     [
       "Can you think of a specific example when {1}?",
       "Really? Always?",
       "What do you think causes {1}?"
     ]},
    {~r/never (.+)/i, :absolute,
     [
       "Never is a long time. Are you sure you never {1}?",
       "What would happen if you {1}?",
       "Why do you think you never {1}?"
     ]}
  ]

  # Default responses when no pattern matches
  @default_responses [
    "Please tell me more.",
    "I see. Go on.",
    "How does that make you feel?",
    "Why do you say that?",
    "Can you elaborate on that?",
    "What comes to mind when you say that?",
    "I'm not sure I understand. Can you explain?",
    "That's interesting. Continue.",
    "How long have you felt this way?",
    "What do you think about that?"
  ]

  @doc """
  Main function to interact with ELIZA. Takes user input and returns a tuple
  with the response and a boolean indicating if this was a goodbye message.

  ## Examples

      iex> BasicGrpcService.Eliza.talk("Hello")
      {"Hello there. How are you feeling today?", false}

      iex> BasicGrpcService.Eliza.talk("I feel sad")
      {"Why do you feel sad?", false}

      iex> BasicGrpcService.Eliza.talk("Goodbye")
      {"Goodbye. I hope our conversation was helpful.", true}

  ## Returns

  A tuple `{response, is_goodbye}` where:
  - `response` is a string containing ELIZA's reply
  - `is_goodbye` is a boolean that is `true` if the user said goodbye, `false` otherwise
  """
  def talk(input) when is_binary(input) do
    input
    |> String.trim()
    |> String.downcase()
    |> process_input()
  end

  # Process the input and generate a response with goodbye indicator
  defp process_input(input) do
    case find_matching_rule(input) do
      {_pattern, rule_type, responses, captures} ->
        response = generate_response(responses, captures)
        is_goodbye = rule_type == :goodbye
        {response, is_goodbye}

      nil ->
        {Enum.random(@default_responses), false}
    end
  end

  # Find the first rule that matches the input
  defp find_matching_rule(input) do
    Enum.find_value(@rules, fn {pattern, rule_type, responses} ->
      case Regex.run(pattern, input) do
        nil -> nil
        [_full_match | captures] -> {pattern, rule_type, responses, captures}
      end
    end)
  end

  # Generate response by selecting random template and replacing placeholders
  defp generate_response(responses, captures) do
    response_template = Enum.random(responses)
    replace_placeholders(response_template, captures)
  end

  # Replace {n} placeholders with captured groups, applying transformations
  defp replace_placeholders(template, captures) do
    captures
    |> Enum.with_index(1)
    |> Enum.reduce(template, fn {capture, index}, acc ->
      transformed_capture = transform_pronouns(capture)
      String.replace(acc, "{#{index}}", transformed_capture)
    end)
  end

  # Transform pronouns and common words (I -> you, etc.)
  defp transform_pronouns(text) do
    text
    |> String.split(" ")
    |> Enum.map(&transform_word/1)
    |> Enum.join(" ")
  end

  # Transform individual words based on transformation rules
  defp transform_word(word) do
    cleaned_word = String.downcase(word)
    Map.get(@transformations, cleaned_word, word)
  end
end
