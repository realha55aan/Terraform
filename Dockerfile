FROM public.ecr.aws/lambda/nodejs:14

COPY app.js ${LAMBDA_TASK_ROOT}

CMD [ "app.handler" ]
