#!/bin/bash
QUOTES=("A chain is only as strong as its weakest link." \
        "A fool and his money are soon parted." \
        "A friend is someone who gives you total freedom to be yourself." \
        "A great man is always willing to be little." \
        "A lion doesn’t concern himself with the opinions of the sheep." \
        "A man is but what he knows." \
        "A mind is a terrible thing to waste." \
        "A mind is like a parachute. It doesn’t work if it isn’t open." \
        "A penny saved is a penny earned." \
        "A picture is worth a thousand words." \
        "A successful man is one who can lay a firm foundation with the bricks others have thrown at him." \
        "Ability is of little account without opportunity." \
        "Actions speak louder than words." \
        "All good things must come to an end." \
        "All limitations are self-imposed." \
        "All our dreams can come true if we have the courage to pursue them." \
        "All that we are is the result of what we have thought." \
        "All that we see and seem is but a dream within a dream." \
        "All things come to those who wait." \
        "All's fair in love and war." \
        "All’s well that ends well." \
        "Always forgive your enemies; nothing annoys them so much." \
        "Always remember that you are absolutely unique. Just like everyone else." \
        "An ounce of action is worth a ton of theory." \
        "Arguing with a fool proves there are two." \
        "Be yourself; everyone else is already taken." \
        "Beauty is in the eye of the beholder." \
        "Beggars can’t be choosers." \
        "Challenges are what make life interesting and overcoming them is what makes life meaningful." \
        "Change your thoughts, and you change your world." \
        "Do not go where the path may lead; go instead where there is no path and leave a trail." \
        "Do what you can, with what you have, where you are." \
        "Don't let your friends you made memories with, become the memories." \
        "Don't put the cart before the horse." \
        "Don’t be afraid to give up the good to go for the great." \
        "Don’t count the days, make the days count." \
        "Don’t count your chickens before they hatch." \
        "Dream big and dare to fail." \
        "Early is on time, on time is late and late is unacceptable." \
        "Even a stopped clock is right twice a day." \
        "Every great dream begins with a dreamer. Always remember, you have within you the strength, the patience, and the passion to reach for the stars to change the world." \
        "Every man is guilty of all the good he did not do." \
        "Everyone will be famous for 15 minutes." \
        "Everything you’ve ever wanted is on the other side of fear." \
        "Familiarity breeds contempt." \
        "Fortune favors the bold." \
        "Genius is eternal patience." \
        "Get busy living or get busy dying." \
        "Great geniuses have the shortest biographies." \
        "Great minds discuss ideas; average minds discuss events; small minds discuss people." \
        "Great minds think alike." \
        "Happiness depends upon ourselves." \
        "Happiness is a direction, not a place." \
        "Have no fear of perfection, you'll never reach it." \
        "He that falls in love with himself will have no rivals." \
        "He who angers you conquers you." \
        "Holding onto anger is like drinking poison and expecting the other person to die." \
        "Honesty is the best policy." \
        "Hope for the best, but prepare for the worst." \
        "I alone cannot change the world, but I can cast a stone across the water to create many ripples." \
        "I am, therefore I think." \
        "I came, I saw, I conquered." \
        "I disapprove of what you say, but I will defend to the death your right to say it." \
        "I have no special talent. I am only passionately curious." \
        "I think, therefore I am." \
        "If I have seen further than others, it is by standing upon the shoulders of giants." \
        "If it ain’t broke, don’t fix it." \
        "If you aren’t going all the way, why go at all?" \
        "If you don't stand for something you will fall for anything." \
        "If you judge people, you have no time to love them." \
        "If you tell the truth, you don’t have to remember anything." \
        "If you want to be happy, be." \
        "If you’re going through hell, keep going." \
        "In order to write about life first you must live it." \
        "In the long run, the sharpest weapon of all is a kind and gentle spirit." \
        "In the middle of difficulty lies opportunity." \
        "In three words I can sum up everything I’ve learned about life: It goes on." \
        "Insanity is doing the same thing over and over again and expecting different results." \
        "It always seems impossible until it’s done." \
        "It is better to fail in originality than to succeed in imitation." \
        "It is never too late to be what you might have been." \
        "It is our choices, that show what we truly are, far more than our abilities." \
        "It isn’t where you came from. It’s where you’re going that counts." \
        "It’s never too late to be who you might have been." \
        "I’m selfish, impatient and a little insecure. I make mistakes, I am out of control and at times hard to handle. But if you can’t handle me at my worst, then you sure as hell don’t deserve me at my best." \
        "Keep your face to the sunshine and you can never see the shadow." \
        "Keep your friends close, but your enemies closer." \
        "Knowing yourself is the beginning of all wisdom." \
        "Knowledge is power." \
        "Knowledge makes a man unfit to be a slave." \
        "Leave no stone unturned." \
        "Leave nothing for tomorrow which can be done today." \
        "Life has no limitations, except the ones you make." \
        "Life is like a box of chocolates. You never know what you’re going to get." \
        "Life is not a problem to be solved, but a reality to be experienced." \
        "Life is ten percent what happens to you and ninety percent how you respond to it." \
        "Life is what happens when you’re busy making other plans." \
        "Life itself is the most wonderful fairy tale." \
        "Life would be tragic if it weren’t funny." \
        "Look before you leap." \
        "Love all, trust a few, do wrong to none." \
        "Many of life’s failures are people who did not realize how close they were to success when they gave up." \
        "May you live all the days of your life." \
        "Necessity is the mother of invention." \
        "Never let the fear of striking out keep you from playing the game." \
        "No one can make you feel inferior without your consent." \
        "No pressure, no diamonds." \
        "Nothing is impossible, the word itself says, ‘I’m possible!’" \
        "Once you’ve accepted your flaws, no one can use them against you." \
        "Originality is nothing but judicious imitation." \
        "Our greatest fear should not be of failure… but of succeeding at things in life that don’t really matter." \
        "People are just as happy as they make up their minds to be." \
        "Power tends to corrupt, and absolute power corrupts absolutely." \
        "Practice makes perfect." \
        "Remember that the happiest people are not those getting more, but those giving more." \
        "Science is what you know. Philosophy is what you don’t know." \
        "Shoot for the moon. Even if you miss, you’ll land among the stars." \
        "Simplicity is the ultimate sophistication." \
        "Sing like no one’s listening, love like you’ve never been hurt, dance like nobody’s watching, and live like it’s heaven on earth." \
        "Stay hungry, stay foolish." \
        "Strive not to be a success, but rather to be of value." \
        "Success is not final, failure is not fatal: it is the courage to continue that counts." \
        "That which does not kill us makes us stronger." \
        "That’s one small step for a man, one giant leap for mankind." \
        "The best way out is always through." \
        "The big lesson in life, baby, is never be scared of anyone or anything." \
        "The early bird catches the worm." \
        "The end doesn’t justify the means." \
        "The further a society drifts from the truth, the more it will hate those that speak it." \
        "The future belongs to those who prepare for it today." \
        "The greatest glory in living lies not in never falling, but in rising every time we fall." \
        "The journey of a thousand miles begins with one step." \
        "The more things change, the more they remain the same." \
        "The only impossible journey is the one you never begin." \
        "The only person you are destined to become is the person you decide to be." \
        "The only thing necessary for the triumph of evil is for good men to do nothing." \
        "The opposite of love is not hate; it’s indifference." \
        "The pen is mightier than the sword." \
        "The power of imagination makes us infinite." \
        "The price of greatness is responsibility." \
        "The purpose of our lives is to be happy." \
        "The question isn’t who is going to let me; it’s who is going to stop me." \
        "The secret of getting ahead is getting started." \
        "The successful warrior is the average man, with laser-like focus." \
        "The time is always right to do what is right." \
        "The way to get started is to quit talking and begin doing." \
        "There is nothing impossible to him who will try." \
        "There’s a sucker born every minute." \
        "This above all: to thine own self be true." \
        "Those who cannot remember the past are condemned to repeat it." \
        "Those who dare to fail miserably can achieve greatly." \
        "Those who make you believe absurdities can make you commit atrocities." \
        "Time is money." \
        "Time you enjoy wasting is not wasted time." \
        "Tis better to have loved and lost than to have never loved at all." \
        "Tough times never last but tough people do." \
        "Try to be a rainbow in someone else’s cloud." \
        "Turn your wounds into wisdom." \
        "Twenty years from now you will be more disappointed by the things that you didn’t do than by the ones you did do." \
        "Two heads are better than one." \
        "Two wrongs don’t make a right." \
        "We are what we repeatedly do; excellence, then, is not an act but a habit." \
        "We design our lives through the power of choices." \
        "We don’t stop playing because we grow old; we grow old because we stop playing." \
        "We have nothing to fear but fear itself." \
        "Well done is better than well said." \
        "What you do speaks so loudly that I cannot hear what you say." \
        "Whatever you do, do with all your might." \
        "When I dare to be powerful – to use my strength in the service of my vision, then it becomes less and less important whether I am afraid." \
        "When life gives you lemons, make lemonade." \
        "When the going gets tough, the tough get going." \
        "When we strive to become better than we are, everything around us becomes better too." \
        "When you reach the end of your rope, tie a knot in it and hang on." \
        "Whether you think you can or you think you can’t, you’re right." \
        "Yesterday is history, tomorrow is a mystery, today is a gift of God, which is why we call it the present." \
        "You are never too old to set another goal or to dream a new dream." \
        "You can discover more about a person in an hour of play than in a year of conversation." \
        "You can not excel at anything you do not love." \
        "You can please some of the people all of the time, you can please all of the people some of the time, but you can’t please all of the people all of the time." \
        "You can’t make an omelet without breaking a few eggs." \
        "You know you’re in love when you can’t fall asleep because reality is finally better than your dreams." \
        "You miss 100 percent of the shots you never take." \
        "You must be the change you wish to see in the world." \
        "You only live once, but if you do it right, once is enough." \
        "You will face many defeats in life, but never let yourself be defeated." \
        "You’ll never find a rainbow if you’re looking down."
)

function print_quote
{
    clear
    printf "${COLOR_PURPLE}Have a amazingly wonderful day!${COLOR_END}\n"
    printf "${COLOR_ORANGE}${QUOTES[$(( RANDOM % ${#QUOTES[@]} ))]}${COLOR_END}\n"
}
