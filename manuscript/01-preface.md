# Preface

When I finished the last book ("The DevOps 2.5 Toolkit: Monitoring, Logging, and Auto-Scaling Kubernetes"), I wanted to take a break from writing for a month or two. I thought that would clear my mind and help me decide which subject to tackle next. Those days were horrible. I could not make up my mind. So many cool and useful tech is emerging and being adopted. I was never as undecided as those weeks. Which should be my next step?

I could explore serverless. That's definitely useful, and it might be considered the next big thing. Or I could dive into Istio. It is probably the biggest and the most important project sitting on top of Kubernetes. Or I could tackle some smaller subjects. Kaniko is the missing link in continuous delivery. Building containers might be the only thing we still do on the host level, and Kaniko allows us to move that process inside containers. How about security scanning? It is one of the things that are mandatory in most organizations, and yet I did not include it in "The DevOps 2.4 Toolkit: Continuous Deployment To Kubernetes". Then there is Skaffold, Prow, KNative, and quite a few other tools that are becoming stable and very useful.

And then it struck me. Jenkins X does all those things and many more. I intentionally excluded it from "The DevOps 2.4 Toolkit: Continuous Deployment To Kubernetes" because at that time (the first half of 2018) it was still too green and it was changing all the time. It was far from stable. But the situation in early 2019 is different. While the project still evolves at a rapid pace and there are quite a few things left to do and polish, Jenkins X is being adopted by many. It has proved its usefulness. Its community is rising, its popularity is enormous, and it is one of the Kubernetes darlings.

So, the decision was made. This book will be dedicated to Jenkins X.

As with other books, the idea is to go deep into the subject. While the first few chapters might (intentionally) seem very basic, we'll explore Jenkins X and many related tools in depth, and we'll try to see the bigger picture. What is it? What does it do and how does it do it? How does it affect our processes? How can we combine it with the things we already have, and which tools should be changed? Is it only about continuous delivery? Does it affect local development? Does it change how we operate Kubernetes?

As with all other books, I do not know in advance where this subject will lead me. I do not plan (much) in advance, and I did not write an index of everything I want to cover. Time will tell what will be the final scope.

What matters is that I want you to be successful and I hope that this book will help you with your career path.

I> If you explore [jenkins-x.io](https://jenkins-x.io/), you might notice some similarities between the content there and in this book. What you read here is not a copy from what's there. Instead, I decided to contribute part of the chapters to the community.

Eventually, you might get stuck and will be in need of help. Or you might want to write a review or comment on the book's content. Please join the [DevOps20](http://slack.devops20toolkit.com/) Slack workspace and post your thoughts, ask questions, or participate in a discussion. If you prefer a more one-on-one conversation, you can use Slack to send me a private message, or send an email to viktor@farcic.com. All the books I have written are very dear to me, and I want you to have a good experience reading them. Part of that experience is the option to reach out to me. Don't be shy.

Please note that this one, just as the previous books, is self-published. I believe that having no intermediaries between the writer and the reader is the best way to go. It allows me to write faster, update the book more frequently, and have more direct communication with you. Your feedback is part of the process. No matter whether you purchased the book while only a few or all chapters were written, the idea is that it will never be truly finished. As time passes, it will require updates so that it is aligned with the change in technology or processes. When possible, I will try to keep it up to date and release updates whenever that makes sense. Eventually, things might change so much that updates are not a good option anymore, and that will be a sign that a whole new book is required. **I will keep writing as long as I continue getting your support.**

# About the Author

Viktor Farcic is a Developer Advocate at [CloudBees](https://www.cloudbees.com/), a member of the [Docker Captains](https://www.docker.com/community/docker-captains) group, and author.

He has coded using a plethora of languages, starting with Pascal (yes, he is old), Basic (before it got Visual prefix), ASP (before it got .NET suffix), C, C++, Perl, Python, ASP.NET, Visual Basic, C#, JavaScript, Java, Scala, etc. He never worked with Fortran. His current favorite is Go.

His big passions are containers, distributed systems, microservices, continuous delivery (CD), continuous deployment (CDP), and test-driven development (TDD).

He often speaks at community gatherings and conferences.

He wrote [The DevOps Toolkit Series](http://www.devopstoolkitseries.com/) and [Test-Driven Java Development](https://www.packtpub.com/application-development/test-driven-java-development).

His random thoughts and tutorials can be found in his blog [TechnologyConversations.com](https://technologyconversations.com/).

# Dedication

To Sara and Eva.
