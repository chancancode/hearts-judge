import java.util.Scanner;

class Player {
    public static void main(String[] args){
        Scanner in = new Scanner(System.in);
        
        System.out.println("READY");
        
        /*** Phase 1: Initialization ***/
        
        /* Anything you print to STDERR will be ignored. You may use
           it to print human readable prompts, so when your program
           is "unplugged" from the judge you can still use it.
        */
        System.err.println("Phase 1");
        
        // Player ID
        int id = in.nextInt();
        in.nextLine(); // Consumes the rest of the line (ie the \n)
        
        // Hand cards
        for(int i=0;i<13;i++){
            in.nextLine(); // Completely ignores the cards for now...
        }
        
        in.nextLine(); // There is an empty line after each phase
        
        /*** Phase 2: Passing cards ***/
        
        System.err.println("Phase 2");
        
        in.nextLine(); // This lines tells you the direction (PL,PR,PA and NP)
        in.nextInt();  // This tells you who you are passing to
        in.nextLine(); // Consumes the rest of the line (ie the \n)
        
        in.nextLine(); // There is an empty line after each phase
        
        /* So in your actual program, you will pick card you would like
           to pass. If some of your choices are invalid card then the
           judge will pick a random (but valid) card for you. Your
           algorithm should be fast - if you used more than 30 seconds
           (subject to change, but it should be no less than 30 seconds)
           then the judge will just pick for you. In this example we will
           just print some (hard coded) random cards and let the judge
           correct us.
        */
        
        System.out.println("S2"); // Passing a 2 of Spades
        System.out.println("S3"); // Passing a 3 of Spades
        System.out.println("S4"); // Passing a 4 of Spades
        
        /*** Phase 2a: Passing cards (confirmation) ***/
        
        System.err.println("Phase 2a");
        
        /* The next three lines tells you the cards that you have actually
           passed. Usually, this should be exactly the same as what you have
           told the judge to pass (and in that order), but if some of your
           choices are invalid (bad format or you don't have that card in
           your hand) then the judge would pick a random (but valid) card
           for you instead. You should check this value and see if it's what
           you expect, otherwise it might messes up your internal data.
        */
        
        in.nextLine();
        in.nextLine();
        in.nextLine();
        
        in.nextLine(); // There is an empty line after each phase
        
        /*** Phase 3: Receiving cards ***/
        
        System.err.println("Phase 3");
        
        in.nextInt(); // This tells you who are passing you the cards
        in.nextLine(); // Consumes the rest of the line (ie the \n)
        
        /* The judge will then echo out ALL your thirdteen cards again,
           and it is guarenteed that the three new cards would come first.
           If you are only interested in knowing what cards have been
           passed on to you then you can ignore the remaining ten lines.
           However, if you do not implment any card-passing strategy (as
           it is in this example), then you can just read everything again
           here.
        */
        
        String[] cards = new String[13]; // Actually store the cards this time
        
        for(int i=0;i<13;i++){
            cards[i] = in.nextLine();
        }
        
        in.nextLine(); // There is an empty line after each phase
        
        /*** GAME ON! ***/
        
        // There are going to be 13 rounds (13 tricks)
        for(int i=0;i<13;i++){
            /*** Phase 4: Playing a card ***/
            
            System.err.println("Phase 4");
            
            in.nextInt(); // This tells you the round number (zero-indexed: first=0, second=1 ...)
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            in.nextInt(); // This tells you who started the round
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            in.nextInt(); // This tells you if the heart has already been broken (T=1,F=0)
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            int n = in.nextInt(); // This tells you how many cards have been played so far
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            // Then n cards follows
            for(int j=0;j<n;j++){
                in.nextLine(); // The j-th card in the trick
            }
            
            in.nextLine(); // There is an empty line after each phase
                        
            /* So in your actual program, you will use the information
               provided to you above to decide which card you would like
               to play. If you played an invalid card (a card you don't
               own, played something other than C2 to start the round,
               played hearts when the heart is not yet broken, etc) then
               the judge will pick a random (but valid) card for you.
               Your algorithm should be fast - if you used more than 30
               seconds (subject to change, but it should be no less than
               30 seconds) then the judge will just pick a card for you.
               In this example we will just play a (hard coded) random
               card and let the judge correct us.
            */
            
            System.out.println("S5"); // Passing a 5 of Spades
            
            /*** Phase 4a: Playing a card (confirmation) ***/
            
            System.err.println("Phase 4a");
            
            /* The next lines tells you the cards that you have actually
               played. Usually, this should be exactly the same as what
               you have told the judge to play, but if your choice is
               invalid or you timed out, then the judge would pick a
               random (but valid) card for you instead. You should check
               this value and see if it's what you expect, otherwise it
               might messes up your internal data.
            */            
            
            in.nextLine();
            in.nextLine(); // There is an empty line after each phase
            
            /*** Phase 5: Round summary ***/
            
            System.err.println("Phase 5");
            
            /* This gives you a summary of this round. You may use
               this information to update your internal data to aid
               future decision-making.
            */
            
            in.nextInt(); // This tells you the round number (zero-indexed: first=0, second=1 ...)
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            in.nextInt(); // This tells you who started the round
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            in.nextInt(); // This tells you if the heart has already been broken (T=1,F=0)
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            // Cards in the trick (always four cards)
            in.nextLine();
            in.nextLine();
            in.nextLine();
            in.nextLine();
            
            in.nextInt(); // This tells you who won the trick
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            in.nextInt(); // This tells how many points are in the trick
            in.nextLine(); // Consumes the rest of the line (ie the \n)
            
            in.nextLine(); // There is an empty line after each phase
        }
        
        /*** Phase 6: Game summary ***/
        
        System.err.println("Phase 6");
        
        // The points each player gained in this game.
        // Your score is the (id)-th entry.
        
        // Player 0
        in.nextInt();
        in.nextLine(); // Consumes the rest of the line (ie the \n)
        
        // Player 1
        in.nextInt();
        in.nextLine(); // Consumes the rest of the line (ie the \n)
        
        // Player 2
        in.nextInt();
        in.nextLine(); // Consumes the rest of the line (ie the \n)
        
        // Player 3
        in.nextInt();
        in.nextLine(); // Consumes the rest of the line (ie the \n)
        
        in.nextLine(); // There is an empty line after each phase
        
        /*** EOF ***/
    }
}